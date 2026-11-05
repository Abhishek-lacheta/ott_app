import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final String id;
  final String videoId;
  final String username;
  final String userAvatar;
  final String text;
  final DateTime createdAt;
  final int likesCount;
  final bool isLiked;

  const Comment({
    required this.id,
    required this.videoId,
    required this.username,
    required this.userAvatar,
    required this.text,
    required this.createdAt,
    this.likesCount = 0,
    this.isLiked = false,
  });

  Comment copyWith({
    String? id,
    String? videoId,
    String? username,
    String? userAvatar,
    String? text,
    DateTime? createdAt,
    int? likesCount,
    bool? isLiked,
  }) {
    return Comment(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  List<Object?> get props => [
    id,
    videoId,
    username,
    userAvatar,
    text,
    createdAt,
    likesCount,
    isLiked,
  ];
}
