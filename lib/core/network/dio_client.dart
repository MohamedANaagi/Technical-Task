import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../errors/app_exceptions.dart';

/// Centralized Dio client with error handling and timeouts.
class DioClient {
  DioClient({String? baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? AppConstants.baseUrl,
          connectTimeout: const Duration(
            seconds: AppConstants.connectTimeoutSeconds,
          ),
          receiveTimeout: const Duration(
            seconds: AppConstants.receiveTimeoutSeconds,
          ),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) => handler.next(_mapError(error)),
      ),
    );
  }

  final Dio _dio;
  Dio get dio => _dio;

  DioException _mapError(DioException error) {
    if (error.type
        case DioExceptionType.connectionTimeout ||
            DioExceptionType.sendTimeout ||
            DioExceptionType.receiveTimeout) {
      return DioException(
        requestOptions: error.requestOptions,
        error: TimeoutException('Request timed out. Please try again.'),
        type: error.type,
      );
    }
    if (error.type == DioExceptionType.connectionError) {
      return DioException(
        requestOptions: error.requestOptions,
        error: OfflineException('No internet connection.'),
        type: error.type,
      );
    }
    final statusCode = error.response?.statusCode;
    final message = error.response?.data is Map
        ? (error.response!.data as Map)['message'] ?? error.message
        : error.message;
    return DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      error: ServerException(
        message?.toString() ??
            'Something went wrong (${statusCode ?? 'unknown'}).',
      ),
      type: error.type,
    );
  }
}
