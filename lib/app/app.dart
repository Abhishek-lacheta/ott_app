import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../features/video_feed/presentation/bloc/video_feed_event.dart';
import 'injection.dart';
import 'routes.dart';

class ShortVideoApp extends StatelessWidget {
  const ShortVideoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ServiceLocator.createVideoFeedBloc()
            ..add(const VideoFeedFetchInitial()),
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: AppRoutes.feed,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
