import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/video.dart';

class VideoActionsBar extends StatelessWidget {
  final Video video;
  final bool isMuted;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onToggleMute;

  const VideoActionsBar({
    super.key,
    required this.video,
    required this.isMuted,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onToggleMute,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Profile Avatar with follow badge
        _buildAvatar(),
        const SizedBox(height: 18),

        // Like Button
        _buildActionButton(
          icon: video.isLiked
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          iconColor: video.isLiked ? AppColors.likeActive : Colors.white,
          label: Formatters.formatCount(video.likesCount),
          onTap: onLike,
        ),
        const SizedBox(height: 16),

        // Comment Button
        _buildActionButton(
          icon: Icons.chat_bubble_rounded,
          iconColor: Colors.white,
          label: Formatters.formatCount(video.commentsCount),
          onTap: onComment,
        ),
        const SizedBox(height: 16),

        // Share Button
        _buildActionButton(
          icon: Icons.share_rounded,
          iconColor: Colors.white,
          label: Formatters.formatCount(video.sharesCount),
          onTap: onShare,
        ),
        const SizedBox(height: 16),

        // Mute / Unmute Button
        _buildActionButton(
          icon: isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          iconColor: isMuted ? Colors.white70 : Colors.white,
          label: isMuted ? 'Muted' : 'Audio',
          onTap: onToggleMute,
        ),
        const SizedBox(height: 20),

        // Vinyl Disc Animation
        _buildVinylDisc(),
      ],
    );
  }

  Widget _buildAvatar() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: video.userAvatar,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(color: AppColors.surfaceLight),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),
        Positioned(
          bottom: -7,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
            ),
            child: Icon(icon, size: 30, color: iconColor),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  color: Colors.black87,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVinylDisc() {
    return Container(
      width: 42,
      height: 42,
      padding: const EdgeInsets.all(7),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Color(0xFF2C2C2E), Color(0xFF1C1C1E), Colors.black],
        ),
        boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 6)],
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: video.userAvatar,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) =>
              const Icon(Icons.music_note, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}
