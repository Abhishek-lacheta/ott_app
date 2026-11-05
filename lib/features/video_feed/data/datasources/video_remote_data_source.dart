import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/video_model.dart';

abstract class VideoRemoteDataSource {
  Future<List<VideoModel>> getVideos({required int page, required int limit});
}

/// Simulated Remote Data Source providing realistic paginated responses
/// using Dio's HTTP architecture and Google Cloud Storage video samples.
class MockVideoRemoteDataSource implements VideoRemoteDataSource {
  final ApiClient? apiClient;
  final bool shouldSimulateError;
  final int totalSimulatedPages;

  MockVideoRemoteDataSource({
    this.apiClient,
    this.shouldSimulateError = false,
    this.totalSimulatedPages = 5,
  });

  @override
  Future<List<VideoModel>> getVideos({
    required int page,
    required int limit,
  }) async {
    if (shouldSimulateError) {
      throw const ServerException('Simulated remote server error (500).');
    }

    // Realistic API network latency simulation
    await Future.delayed(const Duration(milliseconds: 550));

    if (page > totalSimulatedPages) {
      return []; // Reached end of pagination
    }

    final allSamples = ApiConstants.sampleVideosData;
    final totalSamples = allSamples.length;

    // Generate deterministic paginated video items
    final List<VideoModel> result = [];
    final startIndex = (page - 1) * limit;

    for (int i = 0; i < limit; i++) {
      final globalIndex = startIndex + i;
      final sampleIndex = globalIndex % totalSamples;
      final rawSample = allSamples[sampleIndex];

      // Assign a unique page-aware ID so there are no duplicate keys across pagination
      final uniqueId = page == 1
          ? rawSample['id'] as String
          : '${rawSample['id']}_p${page}_$i';

      result.add(
        VideoModel.fromJson({
          ...rawSample,
          'id': uniqueId,
          'caption': page > 1
              ? '${rawSample['caption']} [Feed Page $page]'
              : rawSample['caption'],
        }),
      );
    }

    return result;
  }
}

/// Production implementation using Dio when connected to a live REST API backend
class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  final ApiClient _apiClient;

  VideoRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<VideoModel>> getVideos({
    required int page,
    required int limit,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/videos',
      queryParameters: {'page': page, 'limit': limit},
    );

    if (response.statusCode == 200 && response.data != null) {
      final List<dynamic> data = response.data!['data'] as List<dynamic>? ?? [];
      return data
          .map((item) => VideoModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw ServerException(
        response.statusMessage ?? 'Failed to fetch videos from server',
        response.statusCode,
      );
    }
  }
}
