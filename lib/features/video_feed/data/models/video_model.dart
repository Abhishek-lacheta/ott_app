import '../../domain/entities/video.dart';

class VideoModel {
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

  const VideoModel({
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

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String? ?? '',
      videoUrl: json['videoUrl'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      username: json['username'] as String? ?? '',
      userAvatar: json['userAvatar'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      hashtags:
          (json['hashtags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      sharesCount: (json['sharesCount'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'username': username,
      'userAvatar': userAvatar,
      'caption': caption,
      'hashtags': hashtags,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'isLiked': isLiked,
    };
  }

  Video toEntity() {
    return Video(
      id: id,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      username: username,
      userAvatar: userAvatar,
      caption: caption,
      hashtags: hashtags,
      likesCount: likesCount,
      commentsCount: commentsCount,
      sharesCount: sharesCount,
      isLiked: isLiked,
    );
  }

  factory VideoModel.fromEntity(Video video) {
    return VideoModel(
      id: video.id,
      videoUrl: videoUrlNormalized(video.videoUrl),
      thumbnailUrl: video.thumbnailUrl,
      username: video.username,
      userAvatar: video.userAvatar,
      caption: video.caption,
      hashtags: video.hashtags,
      likesCount: video.likesCount,
      commentsCount: video.commentsCount,
      sharesCount: video.sharesCount,
      isLiked: video.isLiked,
    );
  }

  static String videoUrlNormalized(String url) => url;
}
