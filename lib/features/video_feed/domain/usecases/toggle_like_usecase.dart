import '../repositories/video_repository.dart';

class ToggleLikeUseCase {
  final VideoRepository _repository;

  ToggleLikeUseCase(this._repository);

  Future<void> call({required String videoId, required bool isLiked}) {
    return _repository.toggleLike(videoId, isLiked);
  }
}

