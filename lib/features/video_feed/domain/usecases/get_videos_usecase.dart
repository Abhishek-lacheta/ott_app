import '../entities/video.dart';
import '../repositories/video_repository.dart';

class GetVideosUseCase {
  final VideoRepository _repository;

  GetVideosUseCase(this._repository);

  Future<List<Video>> call({required int page, required int limit}) {
    return _repository.getVideos(page: page, limit: limit);
  }
}

