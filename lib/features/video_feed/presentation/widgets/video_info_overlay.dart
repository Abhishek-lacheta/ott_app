import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/video.dart';

class VideoInfoOverlay extends StatefulWidget {
  final Video video;

  const VideoInfoOverlay({super.key, required this.video});

  @override
  State<VideoInfoOverlay> createState() => _VideoInfoOverlayState();
}

class _VideoInfoOverlayState extends State<VideoInfoOverlay> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Username with verified badge
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '@${widget.video.username}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black87,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.verified_rounded,
              color: AppColors.primaryAccent,
              size: 14,
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Caption & Hashtags
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: RichText(
            maxLines: _isExpanded ? 10 : 2,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.3,
                shadows: [
                  Shadow(
                    color: Colors.black87,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              children: [
                TextSpan(text: widget.video.caption),
                if (widget.video.hashtags.isNotEmpty) ...[
                  const TextSpan(text: ' '),
                  ...widget.video.hashtags.map(
                    (tag) => TextSpan(
                      text: '#$tag ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Audio ticker
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.music_note_rounded,
              size: 14,
              color: Colors.white70,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Original Audio - ${widget.video.username}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 3)],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
