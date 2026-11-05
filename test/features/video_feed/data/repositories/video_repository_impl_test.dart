import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ott_app/core/errors/exceptions.dart';
import 'package:ott_app/core/errors/failures.dart';
import 'package:ott_app/core/network/network_info.dart';
import 'package:ott_app/features/video_feed/data/datasources/video_local_data_source.dart';
import 'package:ott_app/features/video_feed/data/datasources/video_remote_data_source.dart';
import 'package:ott_app/features/video_feed/data/models/video_model.dart';
import 'package:ott_app/features/video_feed/data/repositories/video_repository_impl.dart';

class MockRemoteDataSource extends Mock implements VideoRemoteDataSource {}

class MockLocalDataSource extends Mock implements VideoLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;
  late VideoRepositoryImpl repository;

  const testModel = VideoModel(
    id: 'v1',
    videoUrl: 'https://example.com/v1.mp4',
    thumbnailUrl: 'https://example.com/t1.jpg',
    username: 'test_user',
    userAvatar: 'https://example.com/avatar.jpg',
    caption: 'Caption',
    likesCount: 10,
    commentsCount: 2,
    sharesCount: 1,
    isLiked: false,
  );

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = VideoRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('VideoRepositoryImpl', () {
    test(
      'enriches remote models with local likes and custom comment counts',
      () async {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockRemoteDataSource.getVideos(page: 1, limit: 5),
        ).thenAnswer((_) async => [testModel]);
        when(
          () => mockLocalDataSource.getLikedVideoIds(),
        ).thenAnswer((_) async => {'v1'});
        when(
          () => mockLocalDataSource.getCommentCount('v1'),
        ).thenAnswer((_) async => 8);

        final result = await repository.getVideos(page: 1, limit: 5);

        expect(result.length, equals(1));
        final video = result.first;
        expect(video.id, equals('v1'));
        expect(video.isLiked, isTrue);
        expect(video.likesCount, equals(11)); // 10 + 1 for local like
        expect(video.commentsCount, equals(8)); // overridden by local count
      },
    );

    test('deduplicates video models with identical IDs', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getVideos(page: 1, limit: 5)).thenAnswer(
        (_) async => [testModel, testModel],
      ); // Duplicate in response
      when(
        () => mockLocalDataSource.getLikedVideoIds(),
      ).thenAnswer((_) async => {});
      when(
        () => mockLocalDataSource.getCommentCount(any()),
      ).thenAnswer((_) async => null);

      final result = await repository.getVideos(page: 1, limit: 5);

      expect(result.length, equals(1));
    });

    test(
      'throws ServerFailure when remote data source throws ServerException',
      () async {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockRemoteDataSource.getVideos(page: 1, limit: 5),
        ).thenThrow(const ServerException('500 Error', 500));

        expect(
          () => repository.getVideos(page: 1, limit: 5),
          throwsA(isA<ServerFailure>()),
        );
      },
    );

    test('throws NetworkFailure when offline during pagination', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      expect(
        () => repository.getVideos(page: 2, limit: 5),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });
}
