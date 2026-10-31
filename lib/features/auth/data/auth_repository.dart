import '../../../core/network/api_exceptions.dart';
import '../../../core/storage/preference_service.dart';
import '../models/user_model.dart';
import 'auth_remote_data_source.dart';

abstract class AuthRepository {
  Future<UserModel> signIn({
    required String username,
    required String password,
  });

  /// Restores a previous session: the cached user is returned immediately and
  /// the token is verified in the background.
  Future<UserModel?> restoreSession();

  UserModel? get cachedUser;

  Future<void> signOut();
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.preferenceService,
  });

  final AuthRemoteDataSource remoteDataSource;
  final PreferenceService preferenceService;

  @override
  Future<UserModel> signIn({
    required String username,
    required String password,
  }) async {
    final data = await remoteDataSource.signIn(
      username: username,
      password: password,
    );

    final token = data['accessToken']?.toString() ?? '';
    if (token.isNotEmpty) {
      await preferenceService.saveAccessToken(token);
    }

    final user = UserModel.fromMap(data);
    await preferenceService.saveUserMap(user.toMap());
    return user;
  }

  @override
  Future<UserModel?> restoreSession() async {
    final token = preferenceService.accessToken;
    if (token == null || token.isEmpty) return null;

    final cached = cachedUser;

    try {
      final fresh = UserModel.fromMap(await remoteDataSource.currentUser());
      await preferenceService.saveUserMap(fresh.toMap());
      return fresh;
    } on UnauthorizedException {
      await signOut();
      return null;
    } catch (_) {
      // Offline or the network failed: trusting the cached user keeps the app
      // usable, and the next authenticated call will refresh the token state.
      return cached;
    }
  }

  @override
  UserModel? get cachedUser {
    final data = preferenceService.userMap;
    return data == null ? null : UserModel.fromMap(data);
  }

  @override
  Future<void> signOut() => preferenceService.clearSession();
}
