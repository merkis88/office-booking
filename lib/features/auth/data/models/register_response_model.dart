import 'package:wordpice/core/config/app_api_config.dart';
import 'package:wordpice/features/auth/domain/entities/register_result.dart';
import 'package:wordpice/features/auth/domain/entities/registered_user.dart';

class RegisterResponseModel {
  const RegisterResponseModel({
    required this.success,
    required this.message,
    required this.user,
  });

  final bool success;
  final String message;
  final RegisteredUserModel user;

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      success: json['success'] == true,
      message: (json['message'] as String?)?.trim().isNotEmpty == true
          ? json['message'] as String
          : 'Регистрация прошла успешно',
      user: RegisteredUserModel.fromJson(
        (json['user'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
      ),
    );
  }

  RegisterResult toEntity() {
    return RegisterResult(
      success: success,
      message: message,
      user: user.toEntity(),
    );
  }
}

class RegisteredUserModel {
  const RegisteredUserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.patronymic,
    required this.email,
    required this.roleName,
    required this.post,
    required this.company,
    required this.photo,
    required this.qrHash,
    required this.qrVisible,
    required this.qrMessage,
    required this.qrAvailableFrom,
    required this.qrAvailableUntil,
    required this.qrTimeWindow,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String? patronymic;
  final String email;
  final String? roleName;
  final String? post;
  final String? company;
  final String? photo;
  final String? qrHash;
  final bool qrVisible;
  final String? qrMessage;
  final String? qrAvailableFrom;
  final String? qrAvailableUntil;
  final String? qrTimeWindow;

  factory RegisteredUserModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? role = (json['role'] as Map?)
        ?.cast<String, dynamic>();

    return RegisteredUserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      firstName: (json['first_name'] as String?) ?? '',
      lastName: (json['last_name'] as String?) ?? '',
      patronymic: json['patronymic'] as String?,
      email: (json['email'] as String?) ?? '',
      roleName: role?['role_name'] as String?,
      post: json['post'] as String?,
      company: json['company'] as String?,
      photo: _buildFileUrl(json['photo'] as String?),
      qrHash: json['qr_hash'] as String?,
      qrVisible: json['qr_visible'] == true,
      qrMessage: json['qr_message'] as String?,
      qrAvailableFrom: json['qr_available_from'] as String?,
      qrAvailableUntil: json['qr_available_until'] as String?,
      qrTimeWindow: json['qr_time_window'] as String?,
    );
  }

  factory RegisteredUserModel.fromEntity(RegisteredUser user) {
    return RegisteredUserModel(
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      patronymic: user.patronymic,
      email: user.email,
      roleName: user.roleName,
      post: user.post,
      company: user.company,
      photo: user.photo,
      qrHash: user.qrHash,
      qrVisible: user.qrVisible,
      qrMessage: user.qrMessage,
      qrAvailableFrom: user.qrAvailableFrom,
      qrAvailableUntil: user.qrAvailableUntil,
      qrTimeWindow: user.qrTimeWindow,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'patronymic': patronymic,
      'email': email,
      'post': post,
      'company': company,
      'photo': photo,
      'qr_hash': qrHash,
      'qr_visible': qrVisible,
      'qr_message': qrMessage,
      'qr_available_from': qrAvailableFrom,
      'qr_available_until': qrAvailableUntil,
      'qr_time_window': qrTimeWindow,
      if (roleName != null)
        'role': <String, dynamic>{'role_name': roleName},
    };
  }

  RegisteredUser toEntity() {
    return RegisteredUser(
      id: id,
      firstName: firstName,
      lastName: lastName,
      patronymic: patronymic,
      email: email,
      roleName: roleName,
      post: post,
      company: company,
      photo: photo,
      qrHash: qrHash,
      qrVisible: qrVisible,
      qrMessage: qrMessage,
      qrAvailableFrom: qrAvailableFrom,
      qrAvailableUntil: qrAvailableUntil,
      qrTimeWindow: qrTimeWindow,
    );
  }

  static String? _buildFileUrl(String? rawPath) {
    final trimmed = rawPath?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme) {
      return trimmed;
    }

    final normalizedPath = trimmed.startsWith('/') ? trimmed : '/storage/$trimmed';
    return '${AppApiConfig.baseOrigin}$normalizedPath';
  }
}
