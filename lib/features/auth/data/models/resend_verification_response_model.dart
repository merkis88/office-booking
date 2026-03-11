import 'package:wordpice/features/auth/domain/entities/resend_verification_result.dart';

class ResendVerificationResponseModel {
  const ResendVerificationResponseModel({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;

  factory ResendVerificationResponseModel.fromJson(Map<String, dynamic> json) {
    return ResendVerificationResponseModel(
      success: json['success'] == true,
      message: (json['message'] as String?)?.trim() ?? '',
    );
  }

  ResendVerificationResult toEntity() {
    return ResendVerificationResult(success: success, message: message);
  }
}
