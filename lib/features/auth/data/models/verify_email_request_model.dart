import 'package:wordpice/features/auth/domain/entities/verify_email_params.dart';

class VerifyEmailRequestModel {
  const VerifyEmailRequestModel({
    required this.email,
    required this.code,
  });

  final String email;
  final String code;

  factory VerifyEmailRequestModel.fromParams(VerifyEmailParams params) {
    return VerifyEmailRequestModel(email: params.email, code: params.code);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'email': email,
      'code': code,
    };
  }
}
