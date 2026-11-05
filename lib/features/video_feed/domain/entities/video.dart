import 'package:equatable/equatable.dart';

class Video extends Equatable {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String username;
  final String userAvatar;
  final String caption;
  final List<String> hashtags;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isLiked;

  const Video({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.username,
    required this.userAvatar,
    required this.caption,
    this.hashtags = const [],
    required this.likesCount,
    required this.commentsCount,
    this.sharesCount = 0,
    this.isLiked = false,
  });

  Video copyWith({
    String? id,
    String? videoUrl,
    String? thumbnailUrl,
    String? username,
    String? userAvatar,
    String? caption,
    List<String>? hashtags,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    bool? isLiked,
  }) {
    return Video(
      id: id ?? this.id,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      caption: caption ?? this.caption,
      hashtags: hashtags ?? this.hashtags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  List<Object?> get props => [
    id,
    videoUrl,
    thumbnailUrl,
    username,
    userAvatar,
    caption,
    hashtags,
    likesCount,
    commentsCount,
    sharesCount,
    isLiked,
  ];
}
