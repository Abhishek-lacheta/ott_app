import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ott_app/core/errors/failures.dart';
import 'package:ott_app/core/network/network_info.dart';
import 'package:ott_app/features/video_feed/domain/entities/video.dart';
import 'package:ott_app/features/video_feed/domain/usecases/get_videos_usecase.dart';
import 'package:ott_app/features/video_feed/domain/usecases/persistence_usecases.dart';
import 'package:ott_app/features/video_feed/domain/usecases/toggle_like_usecase.dart';
import 'package:ott_app/features/video_feed/presentation/bloc/video_feed_bloc.dart';
import 'package:ott_app/features/video_feed/presentation/bloc/video_feed_event.dart';
import 'package:ott_app/features/video_feed/presentation/bloc/video_feed_state.dart';

class MockGetVideosUseCase extends Mock implements GetVideosUseCase {}

class MockToggleLikeUseCase extends Mock implements ToggleLikeUseCase {}

class MockGetLastViewedIndexUseCase extends Mock
    implements GetLastViewedIndexUseCase {}

class MockSaveLastViewedIndexUseCase extends Mock
    implements SaveLastViewedIndexUseCase {}

class MockSaveCommentCountUseCase extends Mock
    implements SaveCommentCountUseCase {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockGetVideosUseCase mockGetVideosUseCase;
  late MockToggleLikeUseCase mockToggleLikeUseCase;
  late MockGetLastViewedIndexUseCase mockGetLastViewedIndexUseCase;
  late MockSaveLastViewedIndexUseCase mockSaveLastViewedIndexUseCase;
  late MockSaveCommentCountUseCase mockSaveCommentCountUseCase;
  late MockNetworkInfo mockNetworkInfo;
  late StreamController<bool> connectivityController;

  const sampleVideo1 = Video(
    id: 'v1',
    videoUrl: 'https://example.com/1.mp4',
    thumbnailUrl: 'https://example.com/1.jpg',
    username: 'user_one',
    userAvatar: 'https://example.com/avatar1.jpg',
    caption: 'Caption 1',
    likesCount: 100,
    commentsCount: 10,
    sharesCount: 5,
    isLiked: false,
  );

  const sampleVideo2 = Video(
    id: 'v2',
    videoUrl: 'https://example.com/2.mp4',
    thumbnailUrl: 'https://example.com/2.jpg',
    username: 'user_two',
    userAvatar: 'https://example.com/avatar2.jpg',
    caption: 'Caption 2',
    likesCount: 50,
    commentsCount: 5,
    sharesCount: 2,
    isLiked: false,
  );

  setUp(() {
    mockGetVideosUseCase = MockGetVideosUseCase();
    mockToggleLikeUseCase = MockToggleLikeUseCase();
    mockGetLastViewedIndexUseCase = MockGetLastViewedIndexUseCase();
    mockSaveLastViewedIndexUseCase = MockSaveLastViewedIndexUseCase();
    mockSaveCommentCountUseCase = MockSaveCommentCountUseCase();
    mockNetworkInfo = MockNetworkInfo();
    connectivityController = StreamController<bool>.broadcast();

    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    when(
      () => mockNetworkInfo.onConnectivityChanged,
    ).thenAnswer((_) => connectivityController.stream);
    when(() => mockGetLastViewedIndexUseCase()).thenAnswer((_) async => 0);
  });

  tearDown(() {
    connectivityController.close();
  });

  VideoFeedBloc buildBloc() {
    return VideoFeedBloc(
      getVideosUseCase: mockGetVideosUseCase,
      toggleLikeUseCase: mockToggleLikeUseCase,
      getLastViewedIndexUseCase: mockGetLastViewedIndexUseCase,
      saveLastViewedIndexUseCase: mockSaveLastViewedIndexUseCase,
      saveCommentCountUseCase: mockSaveCommentCountUseCase,
      networkInfo: mockNetworkInfo,
    );
  }

  group('VideoFeedBloc - Initial Fetch', () {
    blocTest<VideoFeedBloc, VideoFeedState>(
      'emits [loading, loaded] when VideoFeedFetchInitial succeeds',
      build: () {
        when(
          () => mockGetVideosUseCase(page: 1, limit: any(named: 'limit')),
        ).thenAnswer((_) async => [sampleVideo1, sampleVideo2]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const VideoFeedFetchInitial()),
      expect: () => [
        const VideoFeedState(status: VideoFeedStatus.loading),
        const VideoFeedState(
          status: VideoFeedStatus.loaded,
          videos: [sampleVideo1, sampleVideo2],
          currentPage: 1,
          hasReachedMax: false,
          initialIndex: 0,
          isOffline: false,
        ),
      ],
    );

    blocTest<VideoFeedBloc, VideoFeedState>(
      'emits [loading, empty] when VideoFeedFetchInitial returns empty list',
      build: () {
        when(
          () => mockGetVideosUseCase(page: 1, limit: any(named: 'limit')),
        ).thenAnswer((_) async => []);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const VideoFeedFetchInitial()),
      expect: () => [
        const VideoFeedState(status: VideoFeedStatus.loading),
        const VideoFeedState(
          status: VideoFeedStatus.empty,
          videos: [],
          currentPage: 1,
          hasReachedMax: true,
          isOffline: false,
        ),
      ],
    );

    blocTest<VideoFeedBloc, VideoFeedState>(
      'emits [loading, error] when VideoFeedFetchInitial fails',
      build: () {
        when(
          () => mockGetVideosUseCase(page: 1, limit: any(named: 'limit')),
        ).thenThrow(const ServerFailure('Server unreachable'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const VideoFeedFetchInitial()),
      expect: () => [
        const VideoFeedState(status: VideoFeedStatus.loading),
        const VideoFeedState(
          status: VideoFeedStatus.error,
          errorMessage: 'Server unreachable',
        ),
      ],
    );
  });

  group('VideoFeedBloc - Pagination & Duplicate Prevention', () {
    blocTest<VideoFeedBloc, VideoFeedState>(
      'appends new videos on VideoFeedLoadMore and prevents duplicate IDs',
      build: () {
        when(
          () => mockGetVideosUseCase(page: 2, limit: any(named: 'limit')),
        ).thenAnswer(
          (_) async => [sampleVideo1, sampleVideo2],
        ); // sampleVideo1 already exists
        return buildBloc();
      },
      seed: () => const VideoFeedState(
        status: VideoFeedStatus.loaded,
        videos: [sampleVideo1],
        currentPage: 1,
      ),
      act: (bloc) => bloc.add(const VideoFeedLoadMore()),
      expect: () => [
        const VideoFeedState(
          status: VideoFeedStatus.loadingMore,
          videos: [sampleVideo1],
          currentPage: 1,
        ),
        const VideoFeedState(
          status: VideoFeedStatus.loaded,
          videos: [
            sampleVideo1,
            sampleVideo2,
          ], // only unique sampleVideo2 appended
          currentPage: 2,
          hasReachedMax: false,
        ),
      ],
    );

    blocTest<VideoFeedBloc, VideoFeedState>(
      'sets hasReachedMax to true when next page returns empty',
      build: () {
        when(
          () => mockGetVideosUseCase(page: 2, limit: any(named: 'limit')),
        ).thenAnswer((_) async => []);
        return buildBloc();
      },
      seed: () => const VideoFeedState(
        status: VideoFeedStatus.loaded,
        videos: [sampleVideo1],
        currentPage: 1,
      ),
      act: (bloc) => bloc.add(const VideoFeedLoadMore()),
      expect: () => [
        const VideoFeedState(
          status: VideoFeedStatus.loadingMore,
          videos: [sampleVideo1],
          currentPage: 1,
        ),
        const VideoFeedState(
          status: VideoFeedStatus.loaded,
          videos: [sampleVideo1],
          currentPage: 1,
          hasReachedMax: true,
        ),
      ],
    );
  });

  group('VideoFeedBloc - Like/Unlike & Optimistic Updates', () {
    blocTest<VideoFeedBloc, VideoFeedState>(
      'optimistically updates isLiked and likesCount, then persists',
      build: () {
        when(
          () => mockToggleLikeUseCase(videoId: 'v1', isLiked: true),
        ).thenAnswer((_) async => Future.value());
        return buildBloc();
      },
      seed: () => const VideoFeedState(
        status: VideoFeedStatus.loaded,
        videos: [sampleVideo1],
      ),
      act: (bloc) => bloc.add(const VideoFeedToggleLike('v1')),
      expect: () => [
        VideoFeedState(
          status: VideoFeedStatus.loaded,
          videos: [sampleVideo1.copyWith(isLiked: true, likesCount: 101)],
        ),
      ],
      verify: (_) {
        verify(
          () => mockToggleLikeUseCase(videoId: 'v1', isLiked: true),
        ).called(1);
      },
    );

    blocTest<VideoFeedBloc, VideoFeedState>(
      'rolls back optimistic like update if persistence fails',
      build: () {
        when(
          () => mockToggleLikeUseCase(videoId: 'v1', isLiked: true),
        ).thenThrow(const CacheFailure('Disk write failed'));
        return buildBloc();
      },
      seed: () => const VideoFeedState(
        status: VideoFeedStatus.loaded,
        videos: [sampleVideo1],
      ),
      act: (bloc) => bloc.add(const VideoFeedToggleLike('v1')),
      expect: () => [
        VideoFeedState(
          status: VideoFeedStatus.loaded,
          videos: [sampleVideo1.copyWith(isLiked: true, likesCount: 101)],
        ),
        const VideoFeedState(
          status: VideoFeedStatus.loaded,
          videos: [sampleVideo1], // Rollback to original
        ),
      ],
    );
  });

  group('VideoFeedBloc - Comment Count Update', () {
    blocTest<VideoFeedBloc, VideoFeedState>(
      'updates comment count for target video and persists it',
      build: () {
        when(
          () => mockSaveCommentCountUseCase(videoId: 'v1', count: 15),
        ).thenAnswer((_) async => Future.value());
        return buildBloc();
      },
      seed: () => const VideoFeedState(
        status: VideoFeedStatus.loaded,
        videos: [sampleVideo1],
      ),
      act: (bloc) =>
          bloc.add(const VideoFeedUpdateCommentCount(videoId: 'v1', count: 15)),
      expect: () => [
        VideoFeedState(
          status: VideoFeedStatus.loaded,
          videos: [sampleVideo1.copyWith(commentsCount: 15)],
        ),
      ],
      verify: (_) {
        verify(
          () => mockSaveCommentCountUseCase(videoId: 'v1', count: 15),
        ).called(1);
      },
    );
  });
}
