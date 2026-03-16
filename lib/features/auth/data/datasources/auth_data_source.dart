import 'package:wordpice/features/auth/data/models/forgot_password_request_model.dart';
import 'package:wordpice/features/auth/data/models/forgot_password_response_model.dart';
import 'package:wordpice/features/auth/data/models/logout_response_model.dart';
import 'package:wordpice/features/auth/data/models/login_request_model.dart';
import 'package:wordpice/features/auth/data/models/login_response_model.dart';
import 'package:wordpice/features/auth/data/models/register_request_model.dart';
import 'package:wordpice/features/auth/data/models/register_response_model.dart';
import 'package:wordpice/features/auth/data/models/resend_verification_request_model.dart';
import 'package:wordpice/features/auth/data/models/resend_verification_response_model.dart';
import 'package:wordpice/features/auth/data/models/verify_email_request_model.dart';
import 'package:wordpice/features/auth/data/models/verify_email_response_model.dart';

abstract class AuthDataSource {
  Future<ForgotPasswordResponseModel> forgotPassword(
    ForgotPasswordRequestModel request,
  );
  Future<LogoutResponseModel> logout();
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<RegisterResponseModel> register(RegisterRequestModel request);
  Future<VerifyEmailResponseModel> verifyEmail(VerifyEmailRequestModel request);
  Future<ResendVerificationResponseModel> resendVerification(
    ResendVerificationRequestModel request,
  );
}

class AuthRequestException implements Exception {
  const AuthRequestException(this.message, {this.fieldErrors = const {}});

  final String message;
  final Map<String, String> fieldErrors;
}
