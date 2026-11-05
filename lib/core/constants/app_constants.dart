/// Application level storage keys and configuration constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'Short Video Feed';

  // Persistence keys
  static const String keyLikedVideoIds = 'pref_liked_video_ids';
  static const String keyLastViewedIndex = 'pref_last_viewed_index';
  static const String keyMutedState = 'pref_is_muted';
  static const String keyCommentCountPrefix = 'pref_comment_count_';

  // Pagination
  static const int paginationThreshold =
      2; // Trigger load more when 2 videos away from end
}
