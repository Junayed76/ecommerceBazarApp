import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/preference_service.dart';
import 'api_exceptions.dart';

/// Thin wrapper around [Dio] that
/// * attaches the stored bearer token to every request, and
/// * converts transport/status errors into [ApiException]s the UI understands.
class DioClient {
  DioClient({required this.preferenceService, Dio? dio, String? baseUrl}) {
    _dio =
        dio ??
        Dio(
          BaseOptions(
            baseUrl: baseUrl ?? ApiConstants.baseUrl,
            connectTimeout: ApiConstants.connectTimeout,
            receiveTimeout: ApiConstants.receiveTimeout,
            sendTimeout: ApiConstants.sendTimeout,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = preferenceService.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final PreferenceService preferenceService;
  late final Dio _dio;

  Dio get dio => _dio;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => _run(() => _dio.get(path, queryParameters: queryParameters));

  Future<Response<dynamic>> post(String path, {dynamic data}) =>
      _run(() => _dio.post(path, data: data));

  Future<Response<dynamic>> put(String path, {dynamic data}) =>
      _run(() => _dio.put(path, data: data));

  Future<Response<dynamic>> delete(String path, {dynamic data}) =>
      _run(() => _dio.delete(path, data: data));

  Future<Response<dynamic>> _run(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw _mapError(error);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(error.toString());
    }
  }

  ApiException _mapError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final data = error.response?.data;
        final message = data is Map && data['message'] != null
            ? data['message'].toString()
            : 'The server returned an unexpected response ($status).';
        if (status == 401 || status == 403) {
          return UnauthorizedException(message);
        }
        if (status == 404) {
          return const NotFoundException();
        }
        return ServerException(message, status);
      case DioExceptionType.cancel:
        return const ApiException('The request was cancelled.');
      case DioExceptionType.badCertificate:
        return const ApiException('Invalid SSL certificate.');
      case DioExceptionType.unknown:
      default:
        return ApiException(
          error.message ?? 'An unexpected network error occurred.',
        );
    }
  }
}
