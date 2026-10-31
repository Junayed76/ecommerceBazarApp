/// Base class for every error the app intentionally surfaces to the UI.
///
/// Repositories translate low-level `DioException`s into one of these so that
/// screens only ever have to display a human readable `message`.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException([
    super.message =
        'No internet connection. Please check your network and try again.',
  ]);
}

class ServerException extends ApiException {
  const ServerException([
    super.message = 'The server ran into a problem. Please try again later.',
    int? statusCode,
  ]) : super(statusCode: statusCode);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([
    super.message = 'Your session has expired. Please sign in again.',
  ]) : super(statusCode: 401);
}

class NotFoundException extends ApiException {
  const NotFoundException([
    super.message = 'The requested resource could not be found.',
  ]) : super(statusCode: 404);
}

class CacheException extends ApiException {
  const CacheException([super.message = 'Failed to read locally saved data.']);
}
