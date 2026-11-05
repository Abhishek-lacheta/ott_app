import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ott_app/core/widgets/error_view.dart';
import 'package:ott_app/core/widgets/loading_view.dart';
import 'package:ott_app/features/video_feed/domain/entities/video.dart';
import 'package:ott_app/features/video_feed/presentation/bloc/video_feed_bloc.dart';
import 'package:ott_app/features/video_feed/presentation/bloc/video_feed_state.dart';
import 'package:ott_app/features/video_feed/presentation/pages/video_feed_screen.dart';

class MockVideoFeedBloc extends Mock implements VideoFeedBloc {}

void main() {
  late MockVideoFeedBloc mockBloc;

  const testVideo = Video(
    id: 'v101',
    videoUrl:
        'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    thumbnailUrl:
        'https://images.unsplash.com/photo-1518709268805-4e9042af9f23',
    username: 'alex_test',
    userAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
    caption: 'Widget test caption for short video feed',
    likesCount: 1540,
    commentsCount: 42,
    sharesCount: 12,
    isLiked: false,
  );

  setUp(() {
    mockBloc = MockVideoFeedBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<VideoFeedBloc>.value(
        value: mockBloc,
        child: const VideoFeedScreen(),
      ),
    );
  }

  testWidgets('displays LoadingView when state is loading', (tester) async {
    when(
      () => mockBloc.state,
    ).thenReturn(const VideoFeedState(status: VideoFeedStatus.loading));
    when(
      () => mockBloc.stream,
    ).thenAnswer((_) => const Stream<VideoFeedState>.empty());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(LoadingView), findsOneWidget);
    expect(find.text('Loading feed...'), findsOneWidget);
  });

  testWidgets('displays ErrorView with retry button when state is error', (
    tester,
  ) async {
    when(() => mockBloc.state).thenReturn(
      const VideoFeedState(
        status: VideoFeedStatus.error,
        errorMessage: 'Network timeout error',
      ),
    );
    when(
      () => mockBloc.stream,
    ).thenAnswer((_) => const Stream<VideoFeedState>.empty());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('Network timeout error'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets('displays top header and bottom nav bar on feed screen', (
    tester,
  ) async {
    when(() => mockBloc.state).thenReturn(
      const VideoFeedState(status: VideoFeedStatus.loaded, videos: [testVideo]),
    );
    when(
      () => mockBloc.stream,
    ).thenAnswer((_) => const Stream<VideoFeedState>.empty());

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Verify header tabs
    expect(find.text('Following'), findsOneWidget);
    expect(find.text('For You'), findsOneWidget);

    // Verify bottom nav items
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
