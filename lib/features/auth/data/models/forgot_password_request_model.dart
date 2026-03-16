import 'package:wordpice/features/auth/domain/entities/forgot_password_params.dart';

class ForgotPasswordRequestModel {
  const ForgotPasswordRequestModel({required this.email});

  final String email;

  factory ForgotPasswordRequestModel.fromParams(ForgotPasswordParams params) {
    return ForgotPasswordRequestModel(email: params.email);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'email': email};
  }
}
