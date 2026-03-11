import 'package:wordpice/features/auth/data/models/register_response_model.dart';
import 'package:wordpice/features/auth/domain/entities/verify_email_result.dart';

class VerifyEmailResponseModel {
  const VerifyEmailResponseModel({
    required this.success,
    required this.message,
    required this.user,
    required this.token,
  });

  final bool success;
  final String message;
  final RegisteredUserModel user;
  final String token;

  factory VerifyEmailResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyEmailResponseModel(
      success: json['success'] == true,
      message: (json['message'] as String?)?.trim() ?? '',
      user: RegisteredUserModel.fromJson(
        (json['user'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
      ),
      token: (json['token'] as String?) ?? '',
    );
  }

  VerifyEmailResult toEntity() {
    return VerifyEmailResult(
      success: success,
      message: message,
      user: user.toEntity(),
      token: token,
    );
  }
}
