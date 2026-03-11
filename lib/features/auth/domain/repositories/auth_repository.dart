import 'package:wordpice/features/auth/domain/entities/logout_result.dart';
import 'package:wordpice/features/auth/domain/entities/login_params.dart';
import 'package:wordpice/features/auth/domain/entities/login_result.dart';
import 'package:wordpice/features/auth/domain/entities/register_params.dart';
import 'package:wordpice/features/auth/domain/entities/register_result.dart';
import 'package:wordpice/features/auth/domain/entities/resend_verification_params.dart';
import 'package:wordpice/features/auth/domain/entities/resend_verification_result.dart';
import 'package:wordpice/features/auth/domain/entities/verify_email_params.dart';
import 'package:wordpice/features/auth/domain/entities/verify_email_result.dart';

abstract class AuthRepository {
  Future<LogoutResult> logout();
  Future<LoginResult> login(LoginParams params);
  Future<RegisterResult> register(RegisterParams params);
  Future<VerifyEmailResult> verifyEmail(VerifyEmailParams params);
  Future<ResendVerificationResult> resendVerification(
    ResendVerificationParams params,
  );
}
