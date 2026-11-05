import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../domain/entities/video.dart';

enum PlaybackStatus {
  uninitialized,
  initializing,
  ready,
  buffering,
  playing,
  paused,
  error,
}

class VideoItemPlaybackState {
  final PlaybackStatus status;
  final String? errorMessage;
  final Duration position;
  final Duration duration;

  const VideoItemPlaybackState({
    this.status = PlaybackStatus.uninitialized,
    this.errorMessage,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  VideoItemPlaybackState copyWith({
    PlaybackStatus? status,
    String? errorMessage,
    Duration? position,
    Duration? duration,
  }) {
    return VideoItemPlaybackState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

/// Centralized Video Controller Manager.
/// Manages controller allocation, preloading adjacent items, pausing off-screen videos,
/// disposing stale controllers, and handling foreground/background app lifecycle transitions.
class VideoControllerManager extends ChangeNotifier
    with WidgetsBindingObserver {
  final Map<int, VideoPlayerController> _controllers = {};
  final Map<int, Future<void>> _initFutures = {};
  final Map<int, VideoItemPlaybackState> _playbackStates = {};
  final Map<int, VoidCallback> _controllerListeners = {};

  int _currentIndex = 0;
  bool _isMuted = false;
  bool _isUserPaused = false;
  bool _isAppInBackground = false;
  List<Video> _videos = [];

  final ValueNotifier<bool> isMutedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isUserPausedNotifier = ValueNotifier<bool>(false);

  VideoControllerManager() {
    WidgetsBinding.instance.addObserver(this);
  }

  int get currentIndex => _currentIndex;
  bool get isMuted => _isMuted;
  bool get isUserPaused => _isUserPaused;

  VideoPlayerController? getController(int index) => _controllers[index];

  VideoItemPlaybackState getPlaybackState(int index) {
    return _playbackStates[index] ?? const VideoItemPlaybackState();
  }

  void updateVideos(List<Video> videos) {
    _videos = videos;
  }

  /// Called when the PageView changes page.
  /// Immediately pauses the old page, cleans up distant controllers,
  /// and initiates play/preload for the new window.
  Future<void> onPageChanged(int newIndex, List<Video> videos) async {
    if (newIndex == _currentIndex && _controllers.containsKey(newIndex)) {
      return;
    }

    _videos = videos;
    final int previousIndex = _currentIndex;
    _currentIndex = newIndex;
    _isUserPaused = false;
    isUserPausedNotifier.value = false;

    // Immediately pause the previous controller to prevent audio/video overlap
    if (_controllers.containsKey(previousIndex)) {
      final prevController = _controllers[previousIndex]!;
      if (prevController.value.isInitialized) {
        await prevController.pause();
      }
    }

    // Evict unused controllers outside [newIndex - 1, newIndex + 1] window
    _evictDistantControllers(newIndex);

    // Initialize & play active controller
    if (newIndex >= 0 && newIndex < _videos.length) {
      await _initializeAndPlay(newIndex, autoPlay: true);
    }

    // Preload next adjacent controller safely
    final nextIndex = newIndex + 1;
    if (nextIndex < _videos.length) {
      _preloadAdjacent(nextIndex);
    }

    // Preload previous adjacent controller if available
    final prevAdjacent = newIndex - 1;
    if (prevAdjacent >= 0) {
      _preloadAdjacent(prevAdjacent);
    }

    notifyListeners();
  }

  /// Preloads an adjacent video controller without starting playback.
  Future<void> _preloadAdjacent(int index) async {
    if (index < 0 || index >= _videos.length) return;
    if (_controllers.containsKey(index)) return; // Already loaded/loading

    try {
      final video = _videos[index];
      await _initController(index, video.videoUrl, autoPlay: false);
    } catch (_) {
      // Ignored for preloading
    }
  }

  /// Initializes and plays the controller at [index].
  Future<void> _initializeAndPlay(int index, {required bool autoPlay}) async {
    if (index < 0 || index >= _videos.length) return;
    final video = _videos[index];

    // If controller already exists and initialized
    if (_controllers.containsKey(index)) {
      final controller = _controllers[index]!;
      if (controller.value.isInitialized) {
        if (autoPlay &&
            index == _currentIndex &&
            !_isUserPaused &&
            !_isAppInBackground) {
          await controller.setVolume(_isMuted ? 0.0 : 1.0);
          await controller.play();
        }
        return;
      }
    }

    await _initController(index, video.videoUrl, autoPlay: autoPlay);
  }

  /// Core controller creation and initialization
  Future<void> _initController(
    int index,
    String videoUrl, {
    required bool autoPlay,
  }) async {
    if (_initFutures.containsKey(index)) {
      await _initFutures[index];
      return;
    }

    _playbackStates[index] =
        (_playbackStates[index] ?? const VideoItemPlaybackState()).copyWith(
          status: PlaybackStatus.initializing,
        );
    notifyListeners();

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
    );

    _controllers[index] = controller;

    final initFuture = controller.initialize();
    _initFutures[index] = initFuture;

    try {
      await initFuture;

      if (!_controllers.containsKey(index) ||
          _controllers[index] != controller) {
        // Disposed while initializing
        await controller.dispose();
        return;
      }

      await controller.setLooping(true);
      await controller.setVolume(_isMuted ? 0.0 : 1.0);

      // Attach listener for buffer/position updates
      void listener() {
        if (!_controllers.containsKey(index)) return;
        final val = controller.value;
        PlaybackStatus status;
        if (val.hasError) {
          status = PlaybackStatus.error;
        } else if (val.isBuffering) {
          status = PlaybackStatus.buffering;
        } else if (val.isPlaying) {
          status = PlaybackStatus.playing;
        } else {
          status = PlaybackStatus.paused;
        }

        _playbackStates[index] = VideoItemPlaybackState(
          status: status,
          errorMessage: val.errorDescription,
          position: val.position,
          duration: val.duration,
        );
        notifyListeners();
      }

      _controllerListeners[index] = listener;
      controller.addListener(listener);

      _playbackStates[index] = VideoItemPlaybackState(
        status: PlaybackStatus.ready,
        duration: controller.value.duration,
      );

      // Only play if it is still the actively viewed page
      if (index == _currentIndex &&
          autoPlay &&
          !_isUserPaused &&
          !_isAppInBackground) {
        await controller.play();
      }

      notifyListeners();
    } catch (e) {
      if (_controllers.containsKey(index) &&
          _controllers[index] == controller) {
        _playbackStates[index] = VideoItemPlaybackState(
          status: PlaybackStatus.error,
          errorMessage: 'Failed to load video. Please check your connection.',
        );
        notifyListeners();
      }
    } finally {
      _initFutures.remove(index);
    }
  }

  /// Evicts and disposes controllers that are more than 1 step away from current index
  void _evictDistantControllers(int activeIndex) {
    final keysToRemove = _controllers.keys.where((idx) {
      return (idx - activeIndex).abs() > 1;
    }).toList();

    for (final idx in keysToRemove) {
      _disposeController(idx);
    }
  }

  void _disposeController(int index) {
    final controller = _controllers.remove(index);
    final listener = _controllerListeners.remove(index);
    _initFutures.remove(index);
    _playbackStates.remove(index);

    if (controller != null) {
      if (listener != null) {
        controller.removeListener(listener);
      }
      controller.pause();
      controller.dispose();
    }
  }

  /// Retry initializing the controller for [index]
  Future<void> retry(int index) async {
    _disposeController(index);
    if (index >= 0 && index < _videos.length) {
      await _initializeAndPlay(index, autoPlay: index == _currentIndex);
    }
  }

  /// Toggle play / pause when the user taps on the active video
  Future<void> togglePlayPause() async {
    final controller = _controllers[_currentIndex];
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      await controller.pause();
      _isUserPaused = true;
    } else {
      await controller.play();
      _isUserPaused = false;
    }

    isUserPausedNotifier.value = _isUserPaused;
    notifyListeners();
  }

  /// Toggle mute/unmute globally across controllers
  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    isMutedNotifier.value = _isMuted;

    for (final controller in _controllers.values) {
      if (controller.value.isInitialized) {
        await controller.setVolume(_isMuted ? 0.0 : 1.0);
      }
    }

    notifyListeners();
  }

  /// Handle App Lifecycle (Background / Foreground transitions)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _isAppInBackground = true;
      final activeController = _controllers[_currentIndex];
      if (activeController != null && activeController.value.isInitialized) {
        activeController.pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      _isAppInBackground = false;
      final activeController = _controllers[_currentIndex];
      if (activeController != null &&
          activeController.value.isInitialized &&
          !_isUserPaused) {
        activeController.play();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    isMutedNotifier.dispose();
    isUserPausedNotifier.dispose();

    for (final entry in _controllers.entries) {
      final listener = _controllerListeners[entry.key];
      if (listener != null) {
        entry.value.removeListener(listener);
      }
      entry.value.pause();
      entry.value.dispose();
    }

    _controllers.clear();
    _controllerListeners.clear();
    _initFutures.clear();
    _playbackStates.clear();
    super.dispose();
  }
}
