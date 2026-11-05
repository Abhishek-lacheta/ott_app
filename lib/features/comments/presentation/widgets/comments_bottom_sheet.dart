import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_view.dart';
import '../cubit/comments_cubit.dart';
import 'comment_tile.dart';

class CommentsBottomSheet extends StatefulWidget {
  final String videoId;
  final int initialCommentCount;
  final ValueChanged<int> onCommentCountUpdated;

  const CommentsBottomSheet({
    super.key,
    required this.videoId,
    required this.initialCommentCount,
    required this.onCommentCountUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required String videoId,
    required int initialCommentCount,
    required ValueChanged<int> onCommentCountUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => CommentsCubit()..loadComments(videoId),
        child: CommentsBottomSheet(
          videoId: videoId,
          initialCommentCount: initialCommentCount,
          onCommentCountUpdated: onCommentCountUpdated,
        ),
      ),
    );
  }

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final cubit = context.read<CommentsCubit>();
    cubit.addComment(text);
    _textController.clear();

    // Notify parent video feed to increment comment count
    final newCount = cubit.state.comments.length;
    widget.onCommentCountUpdated(newCount);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;

    return Container(
      height:
          mediaQuery.size.height * 0.65 + (bottomInset > 0 ? bottomInset : 0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          BlocBuilder<CommentsCubit, CommentsState>(
            builder: (context, state) {
              final count = state.comments.isNotEmpty
                  ? state.comments.length
                  : widget.initialCommentCount;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24),
                    Text(
                      '$count comments',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: AppColors.iconInactive,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1, color: Colors.white12),

          // Comments List
          Expanded(
            child: BlocBuilder<CommentsCubit, CommentsState>(
              builder: (context, state) {
                if (state.status == CommentsStatus.loading) {
                  return const LoadingView(message: 'Loading comments...');
                }

                if (state.comments.isEmpty) {
                  return const Center(
                    child: Text(
                      'No comments yet. Be the first to comment!',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.comments.length,
                  itemBuilder: (context, index) {
                    final comment = state.comments[index];
                    return CommentTile(
                      comment: comment,
                      onLike: () {
                        context.read<CommentsCubit>().toggleCommentLike(
                          comment.id,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Bottom Input bar
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: bottomInset > 0
                  ? bottomInset + 8
                  : mediaQuery.padding.bottom + 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _submitComment,
                  icon: const Icon(Icons.arrow_upward_rounded, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
