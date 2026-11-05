import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/video.dart';
import '../../../comments/presentation/widgets/comments_bottom_sheet.dart';
import '../manager/video_controller_manager.dart';
import 'video_actions_bar.dart';
import 'video_info_overlay.dart';
import 'video_progress_bar.dart';

class VideoPlayerItem extends StatefulWidget {
  final int index;
  final Video video;
  final VideoControllerManager controllerManager;
  final VoidCallback onLike;
  final ValueChanged<int> onCommentCountUpdated;

  const VideoPlayerItem({
    super.key,
    required this.index,
    required this.video,
    required this.controllerManager,
    required this.onLike,
    required this.onCommentCountUpdated,
  });

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem>
    with SingleTickerProviderStateMixin {
  bool _showHeartAnimation = false;
  late AnimationController _heartAnimController;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 40),
    ]).animate(_heartAnimController);
  }

  @override
  void dispose() {
    _heartAnimController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    if (!widget.video.isLiked) {
      widget.onLike();
    }
    setState(() {
      _showHeartAnimation = true;
    });
    _heartAnimController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _showHeartAnimation = false;
        });
      }
    });
  }

  void _handleShare() {
    try {
      SharePlus.instance.share(
        ShareParams(
          text:
              'Check out this video by @${widget.video.username}: ${widget.video.caption}\n${widget.video.videoUrl}',
          subject: 'Watch this short video!',
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share video: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _openComments() {
    CommentsBottomSheet.show(
      context,
      videoId: widget.video.id,
      initialCommentCount: widget.video.commentsCount,
      onCommentCountUpdated: widget.onCommentCountUpdated,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controllerManager,
      builder: (context, _) {
        final controller = widget.controllerManager.getController(widget.index);
        final playbackState = widget.controllerManager.getPlaybackState(
          widget.index,
        );
        final isInitialized =
            controller != null && controller.value.isInitialized;
        final isCurrent = widget.index == widget.controllerManager.currentIndex;

        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Video Layer / Thumbnail Fallback
            GestureDetector(
              onTap: widget.controllerManager.togglePlayPause,
              onDoubleTap: _handleDoubleTap,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (isInitialized)
                    Center(
                      child: AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: VideoPlayer(controller),
                      ),
                    )
                  else
                    CachedNetworkImage(
                      imageUrl: widget.video.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        color: Colors.black,
                        child: const Icon(
                          Icons.videocam_off,
                          color: Colors.white24,
                          size: 48,
                        ),
                      ),
                    ),

                  // Buffering or Initializing Spinner
                  if (playbackState.status == PlaybackStatus.initializing ||
                      playbackState.status == PlaybackStatus.buffering)
                    Container(
                      color: isInitialized
                          ? Colors.transparent
                          : Colors.black38,
                      child: const Center(
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Playback Error Overlay
                  if (playbackState.status == PlaybackStatus.error)
                    Container(
                      color: Colors.black87,
                      child: ErrorView(
                        compact: true,
                        message:
                            playbackState.errorMessage ??
                            'Playback failed. Please retry.',
                        onRetry: () =>
                            widget.controllerManager.retry(widget.index),
                      ),
                    ),

                  // Center Play/Pause indicator when user manually paused
                  if (isCurrent &&
                      widget.controllerManager.isUserPaused &&
                      isInitialized)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 54,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  // Pop-up Heart animation on double tap
                  if (_showHeartAnimation)
                    Center(
                      child: ScaleTransition(
                        scale: _heartScale,
                        child: const Icon(
                          Icons.favorite_rounded,
                          size: 110,
                          color: AppColors.likeActive,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 16),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 2. Top Scrim Gradient
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 120,
              child: IgnorePointer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black54, Colors.transparent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),

            // 3. Bottom Scrim Gradient
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 220,
              child: IgnorePointer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black87],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),

            // 4. Video Details (Username, Caption, Music)
            Positioned(
              left: 16,
              bottom: 24,
              right: 88,
              child: VideoInfoOverlay(video: widget.video),
            ),

            // 5. Vertical Action Bar (Like, Comment, Share, Mute)
            Positioned(
              right: 12,
              bottom: 24,
              child: VideoActionsBar(
                video: widget.video,
                isMuted: widget.controllerManager.isMuted,
                onLike: widget.onLike,
                onComment: _openComments,
                onShare: _handleShare,
                onToggleMute: widget.controllerManager.toggleMute,
              ),
            ),

            // 6. Subtle Bottom Progress Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: VideoProgressBar(controller: controller),
            ),
          ],
        );
      },
    );
  }
}
