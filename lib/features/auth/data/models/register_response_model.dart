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
      photo: json['photo'] as String?,
    );
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
    );
  }
}
