/// API and remote data source constants.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.shortvideo.internal/v1';
  static const int connectTimeoutSeconds = 10;
  static const int receiveTimeoutSeconds = 10;

  static const int defaultPageSize = 5;

  /// High-reliability, public sample MP4 videos with HTTP 200 & byte-range streaming support.
  /// Fully compatible with ExoPlayer, AVPlayer, and Web without authentication or 403 blocks.
  static const List<Map<String, dynamic>> sampleVideosData = [
    {
      'id': 'video_001',
      'videoUrl': 'https://media.w3.org/2010/05/sintel/trailer.mp4',
      'thumbnailUrl':
          'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500&q=80',
      'username': 'alex_wanderer',
      'userAvatar':
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&q=80',
      'caption':
          'Blazing through the mountains at golden hour! ✨ Nature never fails to amaze. #adventure #explore #mountains #vibes',
      'hashtags': ['adventure', 'explore', 'mountains', 'vibes'],
      'likesCount': 14200,
      'commentsCount': 342,
      'sharesCount': 189,
    },
    {
      'id': 'video_002',
      'videoUrl': 'https://vjs.zencdn.net/v/oceans.mp4',
      'thumbnailUrl':
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500&q=80',
      'username': 'ocean_breeze',
      'userAvatar':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&q=80',
      'caption':
          'Escaping the city hustle for coastal tides and salty air. 🌊 Where is your happy place? #travel #ocean #escape #peace',
      'hashtags': ['travel', 'ocean', 'escape', 'peace'],
      'likesCount': 28500,
      'commentsCount': 890,
      'sharesCount': 620,
    },
    {
      'id': 'video_003',
      'videoUrl': 'https://media.w3.org/2010/05/bunny/trailer.mp4',
      'thumbnailUrl':
          'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&q=80',
      'username': 'tech_creator',
      'userAvatar':
          'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150&q=80',
      'caption':
          'Testing the new camera gear! The cinematic slow-mo on this is pure gold. 🎥🚀 #filmmaking #gear #creator #cinematic',
      'hashtags': ['filmmaking', 'gear', 'creator', 'cinematic'],
      'likesCount': 9820,
      'commentsCount': 214,
      'sharesCount': 95,
    },
    {
      'id': 'video_004',
      'videoUrl': 'https://media.w3.org/2010/05/video/movie_300.mp4',
      'thumbnailUrl':
          'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=500&q=80',
      'username': 'dj_pulse',
      'userAvatar':
          'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=150&q=80',
      'caption':
          'Weekend festival vibes! Crowd energy was absolutely electric tonight 🔥🎵 #festival #music #djlife #energy',
      'hashtags': ['festival', 'music', 'djlife', 'energy'],
      'likesCount': 53100,
      'commentsCount': 1420,
      'sharesCount': 2340,
    },
    {
      'id': 'video_005',
      'videoUrl':
          'https://raw.githubusercontent.com/mediaelement/mediaelement-files/master/big_buck_bunny.mp4',
      'thumbnailUrl':
          'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=500&q=80',
      'username': 'cyber_ninja',
      'userAvatar':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&q=80',
      'caption':
          'Late night debugging session turn into this... relatable? 💻😅 Drop a ☕ if you know the feeling. #developer #coding #techhumor',
      'hashtags': ['developer', 'coding', 'techhumor'],
      'likesCount': 34900,
      'commentsCount': 975,
      'sharesCount': 812,
    },
    {
      'id': 'video_006',
      'videoUrl':
          'https://raw.githubusercontent.com/mediaelement/mediaelement-files/master/echo-hereweare.mp4',
      'thumbnailUrl':
          'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=500&q=80',
      'username': 'nature_daily',
      'userAvatar':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&q=80',
      'caption':
          'Forest wildlife in spring. Look at how peaceful this sanctuary feels! 🍃🐰 #nature #wildlife #peaceful #green',
      'hashtags': ['nature', 'wildlife', 'peaceful', 'green'],
      'likesCount': 42800,
      'commentsCount': 624,
      'sharesCount': 530,
    },
  ];
}
