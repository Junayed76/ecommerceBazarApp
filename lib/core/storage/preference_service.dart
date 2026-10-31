import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';

/// Small typed wrapper over [SharedPreferences].
///
/// It is the only place in the app that talks to `SharedPreferences`, which
/// keeps the repositories simple and makes them easy to fake in tests.
class PreferenceService {
  PreferenceService._(this._prefs);

  final SharedPreferences _prefs;

  static Future<PreferenceService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferenceService._(prefs);
  }

  // ---- Session -----------------------------------------------------------
  String? get accessToken => _prefs.getString(ApiConstants.accessTokenKey);

  Future<void> saveAccessToken(String token) =>
      _prefs.setString(ApiConstants.accessTokenKey, token);

  Map<String, dynamic>? get userMap {
    final raw = _prefs.getString(ApiConstants.userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUserMap(Map<String, dynamic> user) =>
      _prefs.setString(ApiConstants.userKey, jsonEncode(user));

  Future<void> clearSession() async {
    await _prefs.remove(ApiConstants.accessTokenKey);
    await _prefs.remove(ApiConstants.userKey);
  }

  // ---- Generic JSON lists ------------------------------------------------
  List<Map<String, dynamic>> readJsonList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> writeJsonList(String key, List<Map<String, dynamic>> items) =>
      _prefs.setString(key, jsonEncode(items));

  Future<void> remove(String key) => _prefs.remove(key);
}
