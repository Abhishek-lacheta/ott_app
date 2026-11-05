import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_client.dart';
import '../core/network/network_info.dart';
import '../features/video_feed/data/datasources/video_local_data_source.dart';
import '../features/video_feed/data/datasources/video_remote_data_source.dart';
import '../features/video_feed/data/repositories/video_repository_impl.dart';
import '../features/video_feed/domain/repositories/video_repository.dart';
import '../features/video_feed/domain/usecases/get_videos_usecase.dart';
import '../features/video_feed/domain/usecases/persistence_usecases.dart';
import '../features/video_feed/domain/usecases/toggle_like_usecase.dart';
import '../features/video_feed/presentation/bloc/video_feed_bloc.dart';

class ServiceLocator {
  ServiceLocator._();

  static late final SharedPreferences sharedPreferences;
  static late final ApiClient apiClient;
  static late final NetworkInfo networkInfo;
  static late final VideoRemoteDataSource videoRemoteDataSource;
  static late final VideoLocalDataSource videoLocalDataSource;
  static late final VideoRepository videoRepository;

  static late final GetVideosUseCase getVideosUseCase;
  static late final ToggleLikeUseCase toggleLikeUseCase;
  static late final GetLikedVideoIdsUseCase getLikedVideoIdsUseCase;
  static late final SaveLastViewedIndexUseCase saveLastViewedIndexUseCase;
  static late final GetLastViewedIndexUseCase getLastViewedIndexUseCase;
  static late final SaveCommentCountUseCase saveCommentCountUseCase;

  static Future<void> init({SharedPreferences? prefs}) async {
    sharedPreferences = prefs ?? await SharedPreferences.getInstance();
    apiClient = ApiClient();
    networkInfo = NetworkInfoImpl(connectivity: Connectivity());

    videoRemoteDataSource = MockVideoRemoteDataSource(apiClient: apiClient);
    videoLocalDataSource = VideoLocalDataSourceImpl(sharedPreferences);

    videoRepository = VideoRepositoryImpl(
      remoteDataSource: videoRemoteDataSource,
      localDataSource: videoLocalDataSource,
      networkInfo: networkInfo,
    );

    getVideosUseCase = GetVideosUseCase(videoRepository);
    toggleLikeUseCase = ToggleLikeUseCase(videoRepository);
    getLikedVideoIdsUseCase = GetLikedVideoIdsUseCase(videoRepository);
    saveLastViewedIndexUseCase = SaveLastViewedIndexUseCase(videoRepository);
    getLastViewedIndexUseCase = GetLastViewedIndexUseCase(videoRepository);
    saveCommentCountUseCase = SaveCommentCountUseCase(videoRepository);
  }

  static VideoFeedBloc createVideoFeedBloc() {
    return VideoFeedBloc(
      getVideosUseCase: getVideosUseCase,
      toggleLikeUseCase: toggleLikeUseCase,
      getLastViewedIndexUseCase: getLastViewedIndexUseCase,
      saveLastViewedIndexUseCase: saveLastViewedIndexUseCase,
      saveCommentCountUseCase: saveCommentCountUseCase,
      networkInfo: networkInfo,
    );
  }
}

