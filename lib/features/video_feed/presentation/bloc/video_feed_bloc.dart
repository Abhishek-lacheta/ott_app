import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/video.dart';
import '../../domain/usecases/get_videos_usecase.dart';
import '../../domain/usecases/persistence_usecases.dart';
import '../../domain/usecases/toggle_like_usecase.dart';
import 'video_feed_event.dart';
import 'video_feed_state.dart';

class VideoFeedBloc extends Bloc<VideoFeedEvent, VideoFeedState> {
  final GetVideosUseCase getVideosUseCase;
  final ToggleLikeUseCase toggleLikeUseCase;
  final GetLastViewedIndexUseCase getLastViewedIndexUseCase;
  final SaveLastViewedIndexUseCase saveLastViewedIndexUseCase;
  final SaveCommentCountUseCase saveCommentCountUseCase;
  final NetworkInfo networkInfo;

  StreamSubscription<bool>? _connectivitySubscription;

  VideoFeedBloc({
    required this.getVideosUseCase,
    required this.toggleLikeUseCase,
    required this.getLastViewedIndexUseCase,
    required this.saveLastViewedIndexUseCase,
    required this.saveCommentCountUseCase,
    required this.networkInfo,
  }) : super(const VideoFeedState()) {
    on<VideoFeedFetchInitial>(_onFetchInitial);
    on<VideoFeedLoadMore>(_onLoadMore);
    on<VideoFeedRefresh>(_onRefresh);
    on<VideoFeedToggleLike>(_onToggleLike);
    on<VideoFeedUpdateCommentCount>(_onUpdateCommentCount);
    on<VideoFeedPageChanged>(_onPageChanged);
    on<VideoFeedConnectivityChanged>(_onConnectivityChanged);
    on<VideoFeedRetry>(_onRetry);

    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    _connectivitySubscription = networkInfo.onConnectivityChanged.listen((
      isConnected,
    ) {
      add(VideoFeedConnectivityChanged(isConnected));
    });
  }

  Future<void> _onFetchInitial(
    VideoFeedFetchInitial event,
    Emitter<VideoFeedState> emit,
  ) async {
    emit(state.copyWith(status: VideoFeedStatus.loading, errorMessage: null));

    try {
      final isConnected = await networkInfo.isConnected;
      final savedIndex = await getLastViewedIndexUseCase();

      final videos = await getVideosUseCase(
        page: 1,
        limit: ApiConstants.defaultPageSize,
      );

      if (videos.isEmpty) {
        emit(
          state.copyWith(
            status: VideoFeedStatus.empty,
            videos: const [],
            currentPage: 1,
            hasReachedMax: true,
            isOffline: !isConnected,
          ),
        );
        return;
      }

      // Ensure restored index is valid within available videos
      final safeInitialIndex = savedIndex < videos.length ? savedIndex : 0;

      emit(
        state.copyWith(
          status: VideoFeedStatus.loaded,
          videos: videos,
          currentPage: 1,
          hasReachedMax: false,
          initialIndex: safeInitialIndex,
          isOffline: !isConnected,
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          status: VideoFeedStatus.error,
          errorMessage: failure.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: VideoFeedStatus.error,
          errorMessage: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  Future<void> _onLoadMore(
    VideoFeedLoadMore event,
    Emitter<VideoFeedState> emit,
  ) async {
    // Avoid concurrent or redundant pagination triggers
    if (state.hasReachedMax ||
        state.status == VideoFeedStatus.loadingMore ||
        state.status == VideoFeedStatus.loading ||
        state.status == VideoFeedStatus.refreshing) {
      return;
    }

    emit(state.copyWith(status: VideoFeedStatus.loadingMore));

    final nextPage = state.currentPage + 1;

    try {
      final newVideos = await getVideosUseCase(
        page: nextPage,
        limit: ApiConstants.defaultPageSize,
      );

      if (newVideos.isEmpty) {
        emit(
          state.copyWith(status: VideoFeedStatus.loaded, hasReachedMax: true),
        );
        return;
      }

      // Prevent duplicate video IDs
      final existingIds = state.videos.map((v) => v.id).toSet();
      final uniqueNewVideos = newVideos
          .where((v) => !existingIds.contains(v.id))
          .toList();

      if (uniqueNewVideos.isEmpty) {
        emit(
          state.copyWith(status: VideoFeedStatus.loaded, hasReachedMax: true),
        );
        return;
      }

      emit(
        state.copyWith(
          status: VideoFeedStatus.loaded,
          videos: [...state.videos, ...uniqueNewVideos],
          currentPage: nextPage,
          hasReachedMax: false,
        ),
      );
    } catch (_) {
      // On pagination failure, retain existing feed and restore loaded status
      emit(state.copyWith(status: VideoFeedStatus.loaded));
    }
  }

  Future<void> _onRefresh(
    VideoFeedRefresh event,
    Emitter<VideoFeedState> emit,
  ) async {
    emit(state.copyWith(status: VideoFeedStatus.refreshing));

    try {
      final freshVideos = await getVideosUseCase(
        page: 1,
        limit: ApiConstants.defaultPageSize,
      );

      if (freshVideos.isEmpty) {
        emit(
          state.copyWith(
            status: VideoFeedStatus.empty,
            videos: const [],
            currentPage: 1,
            hasReachedMax: true,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: VideoFeedStatus.loaded,
          videos: freshVideos,
          currentPage: 1,
          hasReachedMax: false,
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          status: VideoFeedStatus.error,
          errorMessage: failure.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: VideoFeedStatus.error,
          errorMessage: 'Refresh failed: $e',
        ),
      );
    }
  }

  Future<void> _onToggleLike(
    VideoFeedToggleLike event,
    Emitter<VideoFeedState> emit,
  ) async {
    final videoIndex = state.videos.indexWhere((v) => v.id == event.videoId);
    if (videoIndex == -1) return;

    final currentVideo = state.videos[videoIndex];
    final updatedIsLiked = !currentVideo.isLiked;
    final updatedLikesCount = updatedIsLiked
        ? currentVideo.likesCount + 1
        : (currentVideo.likesCount > 0 ? currentVideo.likesCount - 1 : 0);

    final updatedVideo = currentVideo.copyWith(
      isLiked: updatedIsLiked,
      likesCount: updatedLikesCount,
    );

    // Optimistic UI update
    final updatedList = List<Video>.from(state.videos);
    updatedList[videoIndex] = updatedVideo;
    emit(state.copyWith(videos: updatedList));

    // Persist asynchronously
    try {
      await toggleLikeUseCase(videoId: event.videoId, isLiked: updatedIsLiked);
    } catch (_) {
      // Rollback on failure
      final rollbackList = List<Video>.from(state.videos);
      rollbackList[videoIndex] = currentVideo;
      emit(state.copyWith(videos: rollbackList));
    }
  }

  Future<void> _onUpdateCommentCount(
    VideoFeedUpdateCommentCount event,
    Emitter<VideoFeedState> emit,
  ) async {
    final videoIndex = state.videos.indexWhere((v) => v.id == event.videoId);
    if (videoIndex == -1) return;

    final currentVideo = state.videos[videoIndex];
    final updatedVideo = currentVideo.copyWith(commentsCount: event.count);

    final updatedList = List<Video>.from(state.videos);
    updatedList[videoIndex] = updatedVideo;
    emit(state.copyWith(videos: updatedList));

    await saveCommentCountUseCase(videoId: event.videoId, count: event.count);
  }

  Future<void> _onPageChanged(
    VideoFeedPageChanged event,
    Emitter<VideoFeedState> emit,
  ) async {
    await saveLastViewedIndexUseCase(event.index);
  }

  void _onConnectivityChanged(
    VideoFeedConnectivityChanged event,
    Emitter<VideoFeedState> emit,
  ) {
    emit(state.copyWith(isOffline: !event.isConnected));
  }

  void _onRetry(VideoFeedRetry event, Emitter<VideoFeedState> emit) {
    add(const VideoFeedFetchInitial());
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
