import '../repositories/video_repository.dart';

class GetLikedVideoIdsUseCase {
  final VideoRepository _repository;

  GetLikedVideoIdsUseCase(this._repository);

  Future<Set<String>> call() {
    return _repository.getLikedVideoIds();
  }
}

class SaveLastViewedIndexUseCase {
  final VideoRepository _repository;

  SaveLastViewedIndexUseCase(this._repository);

  Future<void> call(int index) {
    return _repository.saveLastViewedIndex(index);
  }
}

class GetLastViewedIndexUseCase {
  final VideoRepository _repository;

  GetLastViewedIndexUseCase(this._repository);

  Future<int> call() {
    return _repository.getLastViewedIndex();
  }
}

class SaveCommentCountUseCase {
  final VideoRepository _repository;

  SaveCommentCountUseCase(this._repository);

  Future<void> call({required String videoId, required int count}) {
    return _repository.saveCommentCount(videoId, count);
  }
}

