import 'package:wordpice/features/auth/data/models/register_response_model.dart';
import 'package:wordpice/features/auth/domain/entities/login_result.dart';

class LoginResponseModel {
  const LoginResponseModel({
    required this.success,
    required this.message,
    required this.user,
    required this.token,
  });

  final bool success;
  final String message;
  final RegisteredUserModel user;
  final String token;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] == true,
      message: (json['message'] as String?)?.trim() ?? '',
      user: RegisteredUserModel.fromJson(
        (json['user'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
      ),
      token: (json['token'] as String?) ?? '',
    );
  }

  LoginResult toEntity() {
    return LoginResult(
      success: success,
      message: message,
      user: user.toEntity(),
      token: token,
    );
  }
}
