import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: const Duration(
                seconds: ApiConstants.connectTimeoutSeconds,
              ),
              receiveTimeout: const Duration(
                seconds: ApiConstants.receiveTimeoutSeconds,
              ),
              sendTimeout: const Duration(
                seconds: ApiConstants.connectTimeoutSeconds,
              ),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          ) {
    _dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        error: true,
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException(
          'Connection timed out or failed. Please check your internet.',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message =
            error.response?.statusMessage ??
            'Server returned status code $statusCode';
        return ServerException(message, statusCode);
      case DioExceptionType.cancel:
        return const ServerException('Request was cancelled.');
      case DioExceptionType.badCertificate:
        return const ServerException('SSL Certificate validation failed.');
      case DioExceptionType.unknown:
      default:
        return NetworkException(
          error.message ?? 'Unknown network error occurred.',
        );
    }
  }
}
