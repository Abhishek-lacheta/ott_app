import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';

abstract class VideoLocalDataSource {
  Future<Set<String>> getLikedVideoIds();
  Future<void> saveLikedVideoIds(Set<String> ids);
  Future<int> getLastViewedIndex();
  Future<void> saveLastViewedIndex(int index);
  Future<int?> getCommentCount(String videoId);
  Future<void> saveCommentCount(String videoId, int count);
}

class VideoLocalDataSourceImpl implements VideoLocalDataSource {
  final SharedPreferences _prefs;

  VideoLocalDataSourceImpl(this._prefs);

  @override
  Future<Set<String>> getLikedVideoIds() async {
    try {
      final list = _prefs.getStringList(AppConstants.keyLikedVideoIds);
      return list?.toSet() ?? <String>{};
    } catch (e) {
      throw CacheException('Failed to read liked video IDs: $e');
    }
  }

  @override
  Future<void> saveLikedVideoIds(Set<String> ids) async {
    try {
      await _prefs.setStringList(AppConstants.keyLikedVideoIds, ids.toList());
    } catch (e) {
      throw CacheException('Failed to save liked video IDs: $e');
    }
  }

  @override
  Future<int> getLastViewedIndex() async {
    try {
      return _prefs.getInt(AppConstants.keyLastViewedIndex) ?? 0;
    } catch (e) {
      throw CacheException('Failed to read last viewed index: $e');
    }
  }

  @override
  Future<void> saveLastViewedIndex(int index) async {
    try {
      await _prefs.setInt(AppConstants.keyLastViewedIndex, index);
    } catch (e) {
      throw CacheException('Failed to save last viewed index: $e');
    }
  }

  @override
  Future<int?> getCommentCount(String videoId) async {
    try {
      return _prefs.getInt('${AppConstants.keyCommentCountPrefix}$videoId');
    } catch (e) {
      throw CacheException('Failed to read comment count: $e');
    }
  }

  @override
  Future<void> saveCommentCount(String videoId, int count) async {
    try {
      await _prefs.setInt(
        '${AppConstants.keyCommentCountPrefix}$videoId',
        count,
      );
    } catch (e) {
      throw CacheException('Failed to save comment count: $e');
    }
  }
}
