import 'package:wordpice/app/app_session.dart';
import 'package:wordpice/core/network/api_client.dart';
import 'package:wordpice/features/auth/data/datasources/auth_data_source.dart';
import 'package:wordpice/features/auth/data/models/login_request_model.dart';
import 'package:wordpice/features/auth/data/models/login_response_model.dart';
import 'package:wordpice/features/auth/data/models/logout_response_model.dart';
import 'package:wordpice/features/auth/data/models/register_request_model.dart';
import 'package:wordpice/features/auth/data/models/register_response_model.dart';
import 'package:wordpice/features/auth/data/models/resend_verification_request_model.dart';
import 'package:wordpice/features/auth/data/models/resend_verification_response_model.dart';
import 'package:wordpice/features/auth/data/models/verify_email_request_model.dart';
import 'package:wordpice/features/auth/data/models/verify_email_response_model.dart';

class AuthRemoteDataSource implements AuthDataSource {
  AuthRemoteDataSource(this._apiClient, this._appSession);

  final ApiClient _apiClient;
  final AppSession _appSession;

  @override
  Future<LogoutResponseModel> logout() async {
    final token = _appSession.token;
    final response = await _apiClient.postJson(
      '/logout',
      body: const <String, dynamic>{},
      headers: token == null || token.isEmpty
          ? null
          : <String, String>{'Authorization': 'Bearer $token'},
    );
    final statusCode = response['statusCode'] as int? ?? 500;

    if (statusCode >= 200 && statusCode < 300 && response['success'] == true) {
      return LogoutResponseModel.fromJson(response);
    }

    final fieldErrors = _extractFieldErrors(response);
    throw AuthRequestException(
      _extractErrorMessage(response, fieldErrors),
      fieldErrors: fieldErrors,
    );
  }

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    final response = await _apiClient.postJson(
      '/login',
      body: request.toJson(),
    );
    final statusCode = response['statusCode'] as int? ?? 500;

    if (statusCode >= 200 && statusCode < 300 && response['success'] == true) {
      return LoginResponseModel.fromJson(response);
    }

    final fieldErrors = _extractFieldErrors(response);
    throw AuthRequestException(
      _extractErrorMessage(response, fieldErrors),
      fieldErrors: fieldErrors,
    );
  }

  @override
  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    final response = await _apiClient.postJson(
      '/register',
      body: request.toJson(),
    );
    return _handleRegisterResponse(response);
  }

  @override
  Future<VerifyEmailResponseModel> verifyEmail(
    VerifyEmailRequestModel request,
  ) async {
    final response = await _apiClient.postJson(
      '/verify-email',
      body: request.toJson(),
    );
    final statusCode = response['statusCode'] as int? ?? 500;

    if (statusCode >= 200 && statusCode < 300 && response['success'] == true) {
      return VerifyEmailResponseModel.fromJson(response);
    }

    final fieldErrors = _extractFieldErrors(response);
    throw AuthRequestException(
      _extractErrorMessage(response, fieldErrors),
      fieldErrors: fieldErrors,
    );
  }

  @override
  Future<ResendVerificationResponseModel> resendVerification(
    ResendVerificationRequestModel request,
  ) async {
    final response = await _apiClient.postJson(
      '/resend-verification',
      body: request.toJson(),
    );
    final statusCode = response['statusCode'] as int? ?? 500;

    if (statusCode >= 200 && statusCode < 300 && response['success'] == true) {
      return ResendVerificationResponseModel.fromJson(response);
    }

    final fieldErrors = _extractFieldErrors(response);
    throw AuthRequestException(
      _extractErrorMessage(response, fieldErrors),
      fieldErrors: fieldErrors,
    );
  }

  RegisterResponseModel _handleRegisterResponse(Map<String, dynamic> response) {
    final statusCode = response['statusCode'] as int? ?? 500;

    if (statusCode >= 200 && statusCode < 300 && response['success'] == true) {
      return RegisterResponseModel.fromJson(response);
    }

    final fieldErrors = _extractFieldErrors(response);
    throw AuthRequestException(
      _extractErrorMessage(response, fieldErrors),
      fieldErrors: fieldErrors,
    );
  }

  Map<String, String> _extractFieldErrors(Map<String, dynamic> response) {
    final result = <String, String>{};
    final errors = response['errors'];

    if (errors is! Map<String, dynamic>) {
      return result;
    }

    for (final entry in errors.entries) {
      final value = entry.value;
      if (value is List && value.isNotEmpty) {
        final first = value.first;
        if (first is String && first.trim().isNotEmpty) {
          result[entry.key] = first.trim();
        }
      }
    }

    return result;
  }

  String _extractErrorMessage(
    Map<String, dynamic> response,
    Map<String, String> fieldErrors,
  ) {
    final message = (response['message'] as String?)?.trim();
    if (message != null && message.isNotEmpty) {
      return message;
    }

    if (fieldErrors.isNotEmpty) {
      return fieldErrors.values.first;
    }

    return 'Не удалось выполнить запрос';
  }
}
