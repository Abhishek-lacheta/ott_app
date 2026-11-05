import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoProgressBar extends StatelessWidget {
  final VideoPlayerController? controller;

  const VideoProgressBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller == null) return const SizedBox.shrink();

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller!,
      builder: (context, value, child) {
        if (!value.isInitialized || value.duration == Duration.zero) {
          return const SizedBox.shrink();
        }

        final double progress =
            (value.position.inMilliseconds / value.duration.inMilliseconds)
                .clamp(0.0, 1.0);

        return Align(
          alignment: Alignment.bottomCenter,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 2.0,
          ),
        );
      },
    );
  }
}
