import 'package:wordpice/features/auth/domain/entities/logout_result.dart';

class LogoutResponseModel {
  const LogoutResponseModel({required this.success, required this.message});

  final bool success;
  final String message;

  factory LogoutResponseModel.fromJson(Map<String, dynamic> json) {
    return LogoutResponseModel(
      success: json['success'] == true,
      message: (json['message'] as String?)?.trim() ?? '',
    );
  }

  LogoutResult toEntity() {
    return LogoutResult(success: success, message: message);
  }
}
