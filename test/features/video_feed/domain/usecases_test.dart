import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ott_app/features/video_feed/domain/entities/video.dart';
import 'package:ott_app/features/video_feed/domain/repositories/video_repository.dart';
import 'package:ott_app/features/video_feed/domain/usecases/get_videos_usecase.dart';
import 'package:ott_app/features/video_feed/domain/usecases/persistence_usecases.dart';
import 'package:ott_app/features/video_feed/domain/usecases/toggle_like_usecase.dart';

class MockVideoRepository extends Mock implements VideoRepository {}

void main() {
  late MockVideoRepository mockRepository;
  late GetVideosUseCase getVideosUseCase;
  late ToggleLikeUseCase toggleLikeUseCase;
  late GetLastViewedIndexUseCase getLastViewedIndexUseCase;
  late SaveLastViewedIndexUseCase saveLastViewedIndexUseCase;

  const testVideo = Video(
    id: 'v1',
    videoUrl: 'https://example.com/v1.mp4',
    thumbnailUrl: 'https://example.com/t1.jpg',
    username: 'test_user',
    userAvatar: 'https://example.com/avatar.jpg',
    caption: 'Test Caption',
    likesCount: 10,
    commentsCount: 2,
    sharesCount: 1,
    isLiked: false,
  );

  setUp(() {
    mockRepository = MockVideoRepository();
    getVideosUseCase = GetVideosUseCase(mockRepository);
    toggleLikeUseCase = ToggleLikeUseCase(mockRepository);
    getLastViewedIndexUseCase = GetLastViewedIndexUseCase(mockRepository);
    saveLastViewedIndexUseCase = SaveLastViewedIndexUseCase(mockRepository);
  });

  group('GetVideosUseCase', () {
    test('should return list of videos from repository', () async {
      when(
        () => mockRepository.getVideos(page: 1, limit: 5),
      ).thenAnswer((_) async => [testVideo]);

      final result = await getVideosUseCase(page: 1, limit: 5);

      expect(result, equals([testVideo]));
      verify(() => mockRepository.getVideos(page: 1, limit: 5)).called(1);
    });
  });

  group('ToggleLikeUseCase', () {
    test('should delegate toggle like call to repository', () async {
      when(
        () => mockRepository.toggleLike('v1', true),
      ).thenAnswer((_) async => Future.value());

      await toggleLikeUseCase(videoId: 'v1', isLiked: true);

      verify(() => mockRepository.toggleLike('v1', true)).called(1);
    });
  });

  group('PersistenceUseCases', () {
    test('should get and save last viewed index', () async {
      when(
        () => mockRepository.getLastViewedIndex(),
      ).thenAnswer((_) async => 3);
      when(
        () => mockRepository.saveLastViewedIndex(4),
      ).thenAnswer((_) async => Future.value());

      final index = await getLastViewedIndexUseCase();
      expect(index, equals(3));

      await saveLastViewedIndexUseCase(4);
      verify(() => mockRepository.saveLastViewedIndex(4)).called(1);
    });
  });
}
