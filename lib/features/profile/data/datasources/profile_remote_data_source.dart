import 'dart:io';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:wordpice/app/app_session.dart';
import 'package:wordpice/core/config/app_api_config.dart';
import 'package:wordpice/core/network/api_client.dart';
import 'package:wordpice/features/auth/domain/entities/registered_user.dart';
import 'package:wordpice/features/profile/data/datasources/profile_data_source.dart';
import 'package:wordpice/features/profile/data/models/change_password_request_model.dart';
import 'package:wordpice/features/profile/data/models/profile_bookings_response_model.dart';
import 'package:wordpice/features/profile/data/models/profile_favorite_places_response_model.dart';
import 'package:wordpice/features/profile/data/models/profile_photo_response_model.dart';
import 'package:wordpice/features/profile/data/models/profile_response_model.dart';
import 'package:wordpice/features/profile/data/models/profile_services_response_model.dart';
import 'package:wordpice/features/profile/data/models/update_profile_request_model.dart';
import 'package:wordpice/features/profile/domain/entities/change_password_params.dart';
import 'package:wordpice/features/profile/domain/entities/profile_rentals_overview.dart';
import 'package:wordpice/features/profile/domain/entities/rental_history_item.dart';
import 'package:wordpice/features/profile/domain/entities/update_profile_params.dart';
import 'package:wordpice/features/profile/presentation/models/profile_request_item.dart';

class ProfileRemoteDataSource implements ProfileDataSource {
  ProfileRemoteDataSource(this._apiClient, this._appSession);

  final ApiClient _apiClient;
  final AppSession _appSession;

  @override
  Future<RegisteredUser> getCurrentProfile() async {
    final response = await _apiClient.getJson(
      '/profile',
      headers: _authorizationHeaders(),
    );
    final statusCode = response['statusCode'] as int? ?? 500;

    if (statusCode >= 200 && statusCode < 300 && response['data'] is Map) {
      return ProfileResponseModel.fromJson(response).toEntity();
    }

    throw ApiConnectionException(
      response['message']?.toString() ?? 'Не удалось получить данные профиля.',
    );
  }

  @override
  Future<RegisteredUser> updateProfile(UpdateProfileParams params) async {
    final request = UpdateProfileRequestModel.fromParams(params);
    final response = await _apiClient.patchJson(
      '/profile',
      body: request.toJson(),
      headers: _authorizationHeaders(),
    );
    final statusCode = response['statusCode'] as int? ?? 500;

    if (statusCode >= 200 && statusCode < 300 && response['data'] is Map) {
      return ProfileResponseModel.fromJson(response).toEntity();
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
      response['message']?.toString() ?? 'Не удалось обновить профиль.',
    );
  }

  @override
  Future<String?> uploadProfilePhoto(String filePath) async {
    final response = await _apiClient.postMultipart(
      '/profile/photo',
      fileField: 'photo',
      filePath: filePath,
      headers: _authorizationHeaders(),
    );
    final statusCode = response['statusCode'] as int? ?? 500;

    if (statusCode >= 200 && statusCode < 300 && response['data'] is Map) {
      return ProfilePhotoResponseModel.fromJson(response).photoUrl;
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
      response['message']?.toString() ?? 'Не удалось обновить фото профиля.',
    );
  }

  @override
  Future<void> deleteAccount(String password) async {
    final response = await _apiClient.deleteJson(
      '/profile',
      body: <String, dynamic>{'password': password.trim()},
      headers: _authorizationHeaders(),
    );
    final statusCode = response['statusCode'] as int? ?? 500;

    if (statusCode == 204 || (statusCode >= 200 && statusCode < 300)) {
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
      response['message']?.toString() ?? 'Не удалось удалить аккаунт.',
    );
  }

  @override
  Future<List<RentalHistoryItem>> getRentalHistory() async {
    final overview = await getRentalsOverview();
    return overview.rentalHistory;
  }

  @override
  Future<List<RentalHistoryItem>> getFavoritePlaces() async {
    final response = await _apiClient.getJson(
      '/places/favorites',
      headers: _authorizationHeaders(),
    );
    final statusCode = response['statusCode'] as int? ?? 500;

    if (statusCode >= 200 && statusCode < 300 && response['data'] is List) {
      return ProfileFavoritePlacesResponseModel.fromJson(response).items;
    }

    throw const ApiConnectionException('Не удалось загрузить избранное.');
  }

  @override
  Future<ProfileRentalsOverview> getRentalsOverview() async {
    final response = await _apiClient.getJson(
      '/bookings/my?sort=-start_time&per_page=100&page=1',
      headers: _authorizationHeaders(),
      baseUrlOverride: AppApiConfig.bookingsBaseUrl,
    );
    final statusCode = response['statusCode'] as int? ?? 500;

    if (statusCode >= 200 && statusCode < 300) {
      return ProfileBookingsResponseModel.fromJson(response).toEntity();
    }

    throw const ApiConnectionException('Не удалось загрузить бронирования.');
  }

  @override
  Future<List<ProfileRequestItem>> getRequests() async {
    final response = await _apiClient.getJson(
      '/services?per_page=100&page=1',
      headers: _authorizationHeaders(),
    );
    final statusCode = response['statusCode'] as int? ?? 500;

    if (statusCode >= 200 && statusCode < 300 && response['success'] == true) {
      return ProfileServicesResponseModel.fromJson(response).items;
    }

    throw const ApiConnectionException('Не удалось загрузить заявки.');
  }

  @override
  Future<String> exportRequestPdf(int requestId) async {
    final bytes = await _apiClient.getBytes(
      '/services/$requestId/export',
      headers: _authorizationHeaders(),
    );

    final fileName = 'request-$requestId.pdf';
    final savedWithSystemPicker = await _savePdfWithSystemPicker(
      fileName: fileName,
      bytes: bytes,
    );

    if (savedWithSystemPicker != null && savedWithSystemPicker.isNotEmpty) {
      return savedWithSystemPicker;
    }

    final preferredDirectory = _preferredDownloadDirectory();
    final savedFile = await _writePdfFile(
      directory: preferredDirectory,
      fileName: fileName,
      bytes: bytes,
    );

    if (savedFile != null) {
      return savedFile.path;
    }

    if (!Platform.isAndroid) {
      final fallbackFile = await _writePdfFile(
        directory: Directory.systemTemp,
        fileName: fileName,
        bytes: bytes,
      );

      if (fallbackFile != null) {
        return fallbackFile.path;
      }
    }

    throw const ApiConnectionException('Не удалось сохранить PDF файл.');
  }

  @override
  Future<void> rescheduleBooking({
    required int bookingId,
    required String startTime,
    required String endTime,
  }) async {
    final response = await _apiClient.postJson(
      '/bookings/$bookingId/reschedule',
      body: <String, dynamic>{
        'start_time': startTime,
        'end_time': endTime,
      },
      headers: _authorizationHeaders(),
      baseUrlOverride: AppApiConfig.bookingsBaseUrl,
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
      response['message']?.toString() ?? 'Не удалось перенести бронирование.',
    );
  }

  @override
  Future<void> cancelBooking(int bookingId) async {
    final response = await _apiClient.postJson(
      '/bookings/$bookingId/cancel',
      body: const <String, dynamic>{},
      headers: _authorizationHeaders(),
      baseUrlOverride: AppApiConfig.bookingsBaseUrl,
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
    if (token == null || token.isEmpty) {
      return null;
    }
    return <String, String>{'Authorization': 'Bearer $token'};
  }

  Directory _preferredDownloadDirectory() {
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Download');
    }
    return Directory.systemTemp;
  }

  Future<File?> _writePdfFile({
    required Directory directory,
    required String fileName,
    required List<int> bytes,
  }) async {
    try {
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final file = File('${directory.path}${Platform.pathSeparator}$fileName');
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } on FileSystemException {
      return null;
    }
  }

  Future<String?> _savePdfWithSystemPicker({
    required String fileName,
    required List<int> bytes,
  }) async {
    try {
      return await FileSaver.instance.saveAs(
        name: fileName.replaceFirst('.pdf', ''),
        bytes: Uint8List.fromList(bytes),
        ext: 'pdf',
        mimeType: MimeType.pdf,
      );
    } catch (_) {
      return null;
    }
  }
}
