import 'package:flutter/material.dart';
import '../features/video_feed/presentation/pages/video_feed_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String feed = '/';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case feed:
      default:
        return MaterialPageRoute(
          builder: (_) => const VideoFeedScreen(),
          settings: settings,
        );
    }
  }
}

