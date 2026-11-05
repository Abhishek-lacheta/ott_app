import 'package:equatable/equatable.dart';
import '../../domain/entities/video.dart';

enum VideoFeedStatus {
  initial,
  loading,
  loaded,
  loadingMore,
  refreshing,
  empty,
  error,
}

class VideoFeedState extends Equatable {
  final VideoFeedStatus status;
  final List<Video> videos;
  final int currentPage;
  final bool hasReachedMax;
  final String? errorMessage;
  final int initialIndex;
  final bool isOffline;

  const VideoFeedState({
    this.status = VideoFeedStatus.initial,
    this.videos = const [],
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.errorMessage,
    this.initialIndex = 0,
    this.isOffline = false,
  });

  VideoFeedState copyWith({
    VideoFeedStatus? status,
    List<Video>? videos,
    int? currentPage,
    bool? hasReachedMax,
    String? errorMessage,
    int? initialIndex,
    bool? isOffline,
  }) {
    return VideoFeedState(
      status: status ?? this.status,
      videos: videos ?? this.videos,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      initialIndex: initialIndex ?? this.initialIndex,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [
    status,
    videos,
    currentPage,
    hasReachedMax,
    errorMessage,
    initialIndex,
    isOffline,
  ];
}
