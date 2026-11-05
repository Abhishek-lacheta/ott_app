import '../entities/video.dart';

abstract class VideoRepository {
  /// Fetches a paginated batch of videos.
  Future<List<Video>> getVideos({required int page, required int limit});

  /// Toggles like status and persists it locally.
  Future<void> toggleLike(String videoId, bool isLiked);

  /// Retrieves the set of all locally liked video IDs.
  Future<Set<String>> getLikedVideoIds();

  /// Persists the last viewed feed index.
  Future<void> saveLastViewedIndex(int index);

  /// Retrieves the last viewed feed index.
  Future<int> getLastViewedIndex();

  /// Persists local comment count updates.
  Future<void> saveCommentCount(String videoId, int count);
}

