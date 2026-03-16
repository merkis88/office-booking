import 'package:wordpice/app/app_session.dart';
import 'package:wordpice/core/config/app_api_config.dart';
import 'package:wordpice/core/network/api_client.dart';
import 'package:wordpice/features/auth/domain/entities/registered_user.dart';
import 'package:wordpice/features/profile/data/datasources/profile_data_source.dart';
import 'package:wordpice/features/profile/data/models/change_password_request_model.dart';
import 'package:wordpice/features/profile/data/models/profile_bookings_response_model.dart';
import 'package:wordpice/features/profile/data/models/profile_response_model.dart';
import 'package:wordpice/features/profile/domain/entities/change_password_params.dart';
import 'package:wordpice/features/profile/domain/entities/profile_rentals_overview.dart';
import 'package:wordpice/features/profile/domain/entities/rental_history_item.dart';

class ProfileRemoteDataSource implements ProfileDataSource {
  ProfileRemoteDataSource(this._apiClient, this._appSession);

  final ApiClient _apiClient;
  final AppSession _appSession;

  @override
  Future<RegisteredUser> getCurrentProfile() async {
    final response = await _apiClient.getJson(
      '/me',
      headers: _authorizationHeaders(),
    );
    final statusCode = response['statusCode'] as int? ?? 500;

    if (statusCode >= 200 && statusCode < 300 && response['success'] == true) {
      return ProfileResponseModel.fromJson(response).toEntity();
    }

    throw const ApiConnectionException('Не удалось получить данные профиля.');
  }

  @override
  Future<List<RentalHistoryItem>> getRentalHistory() async {
    final overview = await getRentalsOverview();
    return overview.rentalHistory;
  }

  @override
  Future<ProfileRentalsOverview> getRentalsOverview() async {
    final response = await _apiClient.getJson(
      '/bookings/my?sort=-start_time&per_page=100&page=1',
      headers: _authorizationHeaders(),
    );
    final statusCode = response['statusCode'] as int? ?? 500;

    if (statusCode >= 200 && statusCode < 300) {
      return ProfileBookingsResponseModel.fromJson(response).toEntity();
    }

    throw const ApiConnectionException('Не удалось загрузить бронирования.');
  }

  @override
  Future<void> cancelBooking(int bookingId) async {
    final response = await _apiClient.postJson(
      '/bookings/$bookingId/cancel',
      body: const <String, dynamic>{},
      headers: _authorizationHeaders(),
    );
    final statusCode = response['statusCode'] as int? ?? 500;

    if (statusCode >= 200 && statusCode < 300) {
      return;
    }

    final errors = response['errors'];
    if (errors is Map) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          throw ApiConnectionException(value.first.toString());
        }
      }
    }

    throw ApiConnectionException(
      response['message']?.toString() ?? 'Не удалось отменить бронь.',
    );
  }

  @override
  Future<String> changePassword(ChangePasswordParams params) async {
    final request = ChangePasswordRequestModel.fromParams(params);
    final response = await _apiClient.putJson(
      '/user/password',
      body: request.toJson(),
      headers: _authorizationHeaders(),
      baseUrlOverride: AppApiConfig.userPasswordBaseUrl,
    );
    final statusCode = response['statusCode'] as int? ?? 500;

    if (statusCode >= 200 && statusCode < 300) {
      return response['message']?.toString() ?? 'Пароль успешно обновлен';
    }

    final errors = response['errors'];
    if (errors is Map) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          throw ApiConnectionException(value.first.toString());
        }
      }
    }

    throw ApiConnectionException(
      response['message']?.toString() ?? 'Не удалось обновить пароль.',
    );
  }

  Map<String, String>? _authorizationHeaders() {
    final token = _appSession.token;
    if (token == null || token.isEmpty) return null;
    return <String, String>{'Authorization': 'Bearer $token'};
  }
}
