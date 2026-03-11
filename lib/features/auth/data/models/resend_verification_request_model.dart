import 'package:wordpice/features/auth/domain/entities/resend_verification_params.dart';

class ResendVerificationRequestModel {
  const ResendVerificationRequestModel({required this.email});

  final String email;

  factory ResendVerificationRequestModel.fromParams(
    ResendVerificationParams params,
  ) {
    return ResendVerificationRequestModel(email: params.email);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'email': email};
  }
}
