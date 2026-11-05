import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/comment.dart';

enum CommentsStatus { initial, loading, loaded, error }

class CommentsState extends Equatable {
  final CommentsStatus status;
  final List<Comment> comments;
  final String? errorMessage;
  final String videoId;

  const CommentsState({
    this.status = CommentsStatus.initial,
    this.comments = const [],
    this.errorMessage,
    this.videoId = '',
  });

  CommentsState copyWith({
    CommentsStatus? status,
    List<Comment>? comments,
    String? errorMessage,
    String? videoId,
  }) {
    return CommentsState(
      status: status ?? this.status,
      comments: comments ?? this.comments,
      errorMessage: errorMessage ?? this.errorMessage,
      videoId: videoId ?? this.videoId,
    );
  }

  @override
  List<Object?> get props => [status, comments, errorMessage, videoId];
}

class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit() : super(const CommentsState());

  /// Loads realistic comments for the given videoId
  Future<void> loadComments(String videoId) async {
    emit(state.copyWith(status: CommentsStatus.loading, videoId: videoId));

    await Future.delayed(const Duration(milliseconds: 300));

    // Sample pre-populated comments
    final sampleComments = [
      Comment(
        id: 'comment_1',
        videoId: videoId,
        username: 'sarah_adventures',
        userAvatar:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=120&q=80',
        text: 'The color grading on this is absolutely unreal! 🔥',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likesCount: 142,
      ),
      Comment(
        id: 'comment_2',
        videoId: videoId,
        username: 'kevin_travels',
        userAvatar:
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=120&q=80',
        text: 'What camera and lens did you use for this shot? 📸',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        likesCount: 89,
      ),
      Comment(
        id: 'comment_3',
        videoId: videoId,
        username: 'elena_sound',
        userAvatar:
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=120&q=80',
        text: 'That audio transition was perfection 🎧✨',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        likesCount: 54,
      ),
      Comment(
        id: 'comment_4',
        videoId: videoId,
        username: 'marcus_code',
        userAvatar:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=120&q=80',
        text: 'Great work! Keep inspiring the community 🚀',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likesCount: 31,
      ),
    ];

    emit(
      state.copyWith(status: CommentsStatus.loaded, comments: sampleComments),
    );
  }

  /// Adds a new comment immediately to the top of the list
  void addComment(String text) {
    if (text.trim().isEmpty) return;

    final newComment = Comment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      videoId: state.videoId,
      username: 'you',
      userAvatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&q=80',
      text: text.trim(),
      createdAt: DateTime.now(),
      likesCount: 0,
      isLiked: false,
    );

    final updated = [newComment, ...state.comments];
    emit(state.copyWith(comments: updated));
  }

  /// Toggle like on an individual comment
  void toggleCommentLike(String commentId) {
    final updated = state.comments.map((c) {
      if (c.id == commentId) {
        final newIsLiked = !c.isLiked;
        return c.copyWith(
          isLiked: newIsLiked,
          likesCount: newIsLiked ? c.likesCount + 1 : c.likesCount - 1,
        );
      }
      return c;
    }).toList();

    emit(state.copyWith(comments: updated));
  }
}
