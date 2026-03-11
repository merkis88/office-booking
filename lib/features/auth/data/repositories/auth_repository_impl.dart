import 'package:wordpice/app/app_session.dart';
import 'package:wordpice/features/auth/data/datasources/auth_data_source.dart';
import 'package:wordpice/features/auth/data/models/login_request_model.dart';
import 'package:wordpice/features/auth/domain/entities/logout_result.dart';
import 'package:wordpice/features/auth/domain/entities/login_params.dart';
import 'package:wordpice/features/auth/domain/entities/login_result.dart';
import 'package:wordpice/features/auth/data/models/register_request_model.dart';
import 'package:wordpice/features/auth/data/models/resend_verification_request_model.dart';
import 'package:wordpice/features/auth/data/models/verify_email_request_model.dart';
import 'package:wordpice/features/auth/domain/entities/register_params.dart';
import 'package:wordpice/features/auth/domain/entities/register_result.dart';
import 'package:wordpice/features/auth/domain/entities/resend_verification_params.dart';
import 'package:wordpice/features/auth/domain/entities/resend_verification_result.dart';
import 'package:wordpice/features/auth/domain/entities/verify_email_params.dart';
import 'package:wordpice/features/auth/domain/entities/verify_email_result.dart';
import 'package:wordpice/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource, {required AppSession appSession})
    : _appSession = appSession;

  final AuthDataSource _dataSource;
  final AppSession _appSession;

  @override
  Future<LogoutResult> logout() async {
    try {
      final response = await _dataSource.logout();
      return response.toEntity();
    } finally {
      _appSession.clear();
    }
  }

  @override
  Future<LoginResult> login(LoginParams params) async {
    final response = await _dataSource.login(
      LoginRequestModel.fromParams(params),
    );
    final result = response.toEntity();
    _appSession.setAuthenticated(token: result.token, user: result.user);
    return result;
  }

  @override
  Future<RegisterResult> register(RegisterParams params) async {
    final response = await _dataSource.register(
      RegisterRequestModel.fromParams(params),
    );
    return response.toEntity();
  }

  @override
  Future<VerifyEmailResult> verifyEmail(VerifyEmailParams params) async {
    final response = await _dataSource.verifyEmail(
      VerifyEmailRequestModel.fromParams(params),
    );
    final result = response.toEntity();
    if (result.token.isNotEmpty) {
      _appSession.setAuthenticated(token: result.token, user: result.user);
    }
    return result;
  }

  @override
  Future<ResendVerificationResult> resendVerification(
    ResendVerificationParams params,
  ) async {
    final response = await _dataSource.resendVerification(
      ResendVerificationRequestModel.fromParams(params),
    );
    return response.toEntity();
  }
}
