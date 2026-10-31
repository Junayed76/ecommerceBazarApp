import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/network/dio_client.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> signIn({
    required String username,
    required String password,
  });

  Future<Map<String, dynamic>> currentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required this.dioClient});

  final DioClient dioClient;

  @override
  Future<Map<String, dynamic>> signIn({
    required String username,
    required String password,
  }) async {
    final response = await dioClient.post(
      ApiConstants.login,
      data: {
        'username': username,
        'password': password,
        'expiresInMins': 120,
      },
    );

    final data = response.data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const ApiException('Unexpected response from the sign in service.');
  }

  @override
  Future<Map<String, dynamic>> currentUser() async {
    final response = await dioClient.get(ApiConstants.currentUser);
    final data = response.data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const ApiException('Could not load your profile.');
  }
}
