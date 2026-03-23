import 'dart:async';

import 'package:wordpice/app/app_session.dart';
import 'package:wordpice/core/config/app_api_config.dart';
import 'package:wordpice/core/network/api_client.dart';
import 'package:wordpice/features/rentals/data/datasources/rentals_data_source.dart';
import 'package:wordpice/features/rentals/data/models/create_booking_request_model.dart';
import 'package:wordpice/features/rentals/data/models/create_booking_response_model.dart';
import 'package:wordpice/features/rentals/data/models/rental_place_details_response_model.dart';
import 'package:wordpice/features/rentals/data/models/rental_places_response_model.dart';

class RentalsRemoteDataSource implements RentalsDataSource {
  RentalsRemoteDataSource(this._apiClient, this._appSession);

  static const int _maxAttempts = 3;

  final ApiClient _apiClient;
  final AppSession _appSession;

  @override
  Future<RentalPlacesResponseModel> getPlaces({
    required String type,
    String? date,
    required int minPrice,
    required int maxPrice,
  }) async {
    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final dateQuery = date == null || date.isEmpty ? '' : '&date=$date';
        final response = await _apiClient.getJson(
          '/places?type=$type$dateQuery&min_price=$minPrice&max_price=$maxPrice',
          headers: _authorizationHeaders(),
        );

        final statusCode = response['statusCode'] as int? ?? 500;
        if (statusCode >= 200 && statusCode < 300) {
          return RentalPlacesResponseModel.fromJson(response);
        }

        throw ApiConnectionException(
          _extractErrorMessage(
            response,
            fallbackMessage: 'Не удалось загрузить помещения.',
          ),
        );
      } on ApiConnectionException catch (error) {
        if (attempt == _maxAttempts || !_shouldRetry(error.message)) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
      }
    }

    throw const ApiConnectionException('Не удалось загрузить помещения.');
  }

  @override
  Future<RentalPlaceDetailsResponseModel> getPlaceDetails({
    required int placeId,
    String? date,
  }) async {
    final response = await _apiClient.getJson(
      '/places/$placeId',
      headers: _authorizationHeaders(),
    );

    final statusCode = response['statusCode'] as int? ?? 500;
    if (statusCode >= 200 && statusCode < 300) {
      return RentalPlaceDetailsResponseModel.fromJson(response);
    }

    throw ApiConnectionException(
      _extractErrorMessage(
        response,
        fallbackMessage: 'Не удалось загрузить информацию о помещении.',
      ),
    );
  }

  @override
  Future<CreateBookingResponseModel> createBooking(
    CreateBookingRequestModel request,
  ) async {
    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final response = await _apiClient.postJson(
          '/bookings',
          body: request.toJson(),
          headers: _authorizationHeaders(),
          baseUrlOverride: AppApiConfig.bookingsBaseUrl,
        );

        final statusCode = response['statusCode'] as int? ?? 500;
        if (statusCode >= 200 && statusCode < 300) {
          return CreateBookingResponseModel.fromJson(response);
        }

        throw ApiConnectionException(
          _extractErrorMessage(
            response,
            fallbackMessage: 'Не удалось создать бронирование.',
          ),
        );
      } on ApiConnectionException catch (error) {
        if (attempt == _maxAttempts || !_shouldRetry(error.message)) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
      }
    }

    throw const ApiConnectionException('Не удалось создать бронирование.');
  }

  @override
  Future<String?> createUserQr({
    required int bookingId,
    required String email,
  }) async {
    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final response = await _apiClient.postJson(
          '/qr/$bookingId/user-qr',
          body: <String, dynamic>{'email': email},
          headers: _authorizationHeaders(),
        );

        final statusCode = response['statusCode'] as int? ?? 500;
        if (statusCode >= 200 && statusCode < 300) {
          return _extractQrHash(response);
        }

        throw ApiConnectionException(
          _extractErrorMessage(
            response,
            fallbackMessage: 'Не удалось создать QR-код для бронирования.',
          ),
        );
      } on ApiConnectionException catch (error) {
        if (attempt == _maxAttempts || !_shouldRetry(error.message)) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
      }
    }

    throw const ApiConnectionException(
      'Не удалось создать QR-код для бронирования.',
    );
  }

  @override
  Future<void> addFavorite({required int placeId}) async {
    await _runFavoriteRequest(
      () => _apiClient.postJson(
        '/places/$placeId/store-favorite',
        body: const <String, dynamic>{},
        headers: _authorizationHeaders(),
      ),
      fallbackMessage: 'Не удалось добавить помещение в избранное.',
    );
  }

  @override
  Future<void> removeFavorite({required int placeId}) async {
    await _runFavoriteRequest(
      () => _apiClient.deleteJson(
        '/places/$placeId/remove-favorite',
        headers: _authorizationHeaders(),
      ),
      fallbackMessage: 'Не удалось удалить помещение из избранного.',
    );
  }

  @override
  Future<void> archivePlace({required int placeId}) async {
    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final response = await _apiClient.postJson(
          '/admin/places/$placeId/archive',
          body: const <String, dynamic>{},
          headers: _authorizationHeaders(),
        );

        final statusCode = response['statusCode'] as int? ?? 500;
        if (statusCode >= 200 && statusCode < 300) {
          return;
        }

        throw ApiConnectionException(
          _extractErrorMessage(
            response,
            fallbackMessage: 'Не удалось отправить помещение в архив.',
          ),
        );
      } on ApiConnectionException catch (error) {
        if (attempt == _maxAttempts || !_shouldRetry(error.message)) {
          rethrow;
        }
        await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
      }
    }

    throw const ApiConnectionException(
      'Не удалось отправить помещение в архив.',
    );
  }

  Future<void> _runFavoriteRequest(
    Future<Map<String, dynamic>> Function() request, {
    required String fallbackMessage,
  }) async {
    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final response = await request();
        final statusCode = response['statusCode'] as int? ?? 500;
        if (statusCode >= 200 && statusCode < 300) {
          return;
        }

        throw ApiConnectionException(
          _extractErrorMessage(response, fallbackMessage: fallbackMessage),
        );
      } on ApiConnectionException catch (error) {
        if (attempt == _maxAttempts || !_shouldRetry(error.message)) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
      }
    }

    throw ApiConnectionException(fallbackMessage);
  }

  Map<String, String>? _authorizationHeaders() {
    final token = _appSession.token;
    if (token == null || token.isEmpty) return null;
    return <String, String>{'Authorization': 'Bearer $token'};
  }

  bool _shouldRetry(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('сервер') ||
        normalized.contains('запрос') ||
        normalized.contains('ответ') ||
        normalized.contains('недоступен') ||
        normalized.contains('timeout');
  }

  String _extractErrorMessage(
    Map<String, dynamic> response, {
    required String fallbackMessage,
  }) {
    final errors = response['errors'];
    if (errors is Map<String, dynamic>) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          final first = value.first?.toString().trim();
          if (first != null && first.isNotEmpty) {
            return first;
          }
        }

        final text = value?.toString().trim();
        if (text != null && text.isNotEmpty) {
          return text;
        }
      }
    }

    final message = response['message']?.toString().trim();
    if (message != null && message.isNotEmpty) {
      return message;
    }

    return fallbackMessage;
  }

  String? _extractQrHash(Map<String, dynamic> response) {
    final directHash = response['hash']?.toString().trim();
    if (directHash != null && directHash.isNotEmpty) {
      return directHash;
    }

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      final nestedHash = data['hash']?.toString().trim();
      if (nestedHash != null && nestedHash.isNotEmpty) {
        return nestedHash;
      }

      final qrs = data['qrs'];
      if (qrs is List) {
        for (final item in qrs.whereType<Map>()) {
          final hash = item['hash']?.toString().trim();
          if (hash != null && hash.isNotEmpty) {
            return hash;
          }
        }
      }
    }

    return null;
  }
}
