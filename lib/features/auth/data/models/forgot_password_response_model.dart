import 'package:wordpice/features/auth/domain/entities/forgot_password_result.dart';

class ForgotPasswordResponseModel {
  const ForgotPasswordResponseModel({required this.message});

  factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponseModel(
      message: (json['message'] as String? ?? '').trim(),
    );
  }

  final String message;

  ForgotPasswordResult toEntity() {
    return ForgotPasswordResult(message: message);
  }
}
