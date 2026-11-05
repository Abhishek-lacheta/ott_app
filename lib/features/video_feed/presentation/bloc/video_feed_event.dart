import 'package:equatable/equatable.dart';

abstract class VideoFeedEvent extends Equatable {
  const VideoFeedEvent();

  @override
  List<Object?> get props => [];
}

class VideoFeedFetchInitial extends VideoFeedEvent {
  const VideoFeedFetchInitial();
}

class VideoFeedLoadMore extends VideoFeedEvent {
  const VideoFeedLoadMore();
}

class VideoFeedRefresh extends VideoFeedEvent {
  const VideoFeedRefresh();
}

class VideoFeedToggleLike extends VideoFeedEvent {
  final String videoId;

  const VideoFeedToggleLike(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

class VideoFeedUpdateCommentCount extends VideoFeedEvent {
  final String videoId;
  final int count;

  const VideoFeedUpdateCommentCount({
    required this.videoId,
    required this.count,
  });

  @override
  List<Object?> get props => [videoId, count];
}

class VideoFeedPageChanged extends VideoFeedEvent {
  final int index;

  const VideoFeedPageChanged(this.index);

  @override
  List<Object?> get props => [index];
}

class VideoFeedConnectivityChanged extends VideoFeedEvent {
  final bool isConnected;

  const VideoFeedConnectivityChanged(this.isConnected);

  @override
  List<Object?> get props => [isConnected];
}

class VideoFeedRetry extends VideoFeedEvent {
  const VideoFeedRetry();
}

