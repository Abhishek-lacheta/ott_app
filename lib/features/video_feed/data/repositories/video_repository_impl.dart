import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/video.dart';
import '../../domain/repositories/video_repository.dart';
import '../datasources/video_local_data_source.dart';
import '../datasources/video_remote_data_source.dart';

class VideoRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource remoteDataSource;
  final VideoLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  VideoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<Video>> getVideos({required int page, required int limit}) async {
    final isOnline = await networkInfo.isConnected;
    if (!isOnline && page > 1) {
      throw const NetworkFailure();
    }

    try {
      final remoteModels = await remoteDataSource.getVideos(
        page: page,
        limit: limit,
      );

      // Enrich with local user interactions
      final likedIds = await localDataSource.getLikedVideoIds();

      final List<Video> result = [];
      final Set<String> seenIds = {};

      for (final model in remoteModels) {
        if (seenIds.contains(model.id)) continue;
        seenIds.add(model.id);

        final isLikedLocally = likedIds.contains(model.id);
        final localCommentCount = await localDataSource.getCommentCount(
          model.id,
        );

        final entity = model.toEntity().copyWith(
          isLiked: isLikedLocally,
          likesCount: isLikedLocally
              ? (model.isLiked ? model.likesCount : model.likesCount + 1)
              : (model.isLiked ? model.likesCount - 1 : model.likesCount),
          commentsCount: localCommentCount ?? model.commentsCount,
        );

        result.add(entity);
      }

      return result;
    } on ServerException catch (e) {
      throw ServerFailure(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  Future<void> toggleLike(String videoId, bool isLiked) async {
    try {
      final currentLiked = await localDataSource.getLikedVideoIds();
      final updated = Set<String>.from(currentLiked);

      if (isLiked) {
        updated.add(videoId);
      } else {
        updated.remove(videoId);
      }

      await localDataSource.saveLikedVideoIds(updated);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<Set<String>> getLikedVideoIds() async {
    try {
      return await localDataSource.getLikedVideoIds();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<void> saveLastViewedIndex(int index) async {
    try {
      await localDataSource.saveLastViewedIndex(index);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<int> getLastViewedIndex() async {
    try {
      return await localDataSource.getLastViewedIndex();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<void> saveCommentCount(String videoId, int count) async {
    try {
      await localDataSource.saveCommentCount(videoId, count);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }
}
