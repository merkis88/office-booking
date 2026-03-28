import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wordpice/features/auth/data/models/register_response_model.dart';
import 'package:wordpice/features/auth/domain/entities/registered_user.dart';

class AppSessionStorage {
  AppSessionStorage({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  final FlutterSecureStorage _storage;

  Future<void> saveSession({
    required String token,
    required RegisteredUser user,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(
      key: _userKey,
      value: jsonEncode(RegisteredUserModel.fromEntity(user).toJson()),
    );
  }

  Future<StoredSession?> readSession() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      final rawUser = await _storage.read(key: _userKey);

      if (token == null || token.isEmpty || rawUser == null || rawUser.isEmpty) {
        return null;
      }

      final dynamic decoded = jsonDecode(rawUser);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final user = RegisteredUserModel.fromJson(decoded).toEntity();
      return StoredSession(token: token, user: user);
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}

class StoredSession {
  const StoredSession({
    required this.token,
    required this.user,
  });

  final String token;
  final RegisteredUser user;
}
