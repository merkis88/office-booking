import 'package:wordpice/app/app_session.dart';
import 'package:wordpice/core/network/api_client.dart';
import 'package:wordpice/features/archive/data/datasources/archive_data_source.dart';
import 'package:wordpice/features/archive/data/models/archive_places_response_model.dart';
import 'package:wordpice/features/archive/presentation/models/archive_item.dart';

class ArchiveRemoteDataSource implements ArchiveDataSource {
  ArchiveRemoteDataSource(this._apiClient, this._appSession);

  static const int _maxAttempts = 3;

  final ApiClient _apiClient;
  final AppSession _appSession;

  @override
  Future<List<ArchiveItem>> getArchivedPlaces() async {
    final response = await _apiClient.getJson(
      '/admin/places?archived=1',
      headers: _authorizationHeaders(),
    );

    final statusCode = response['statusCode'] as int? ?? 500;
    if (statusCode >= 200 && statusCode < 300 && response['success'] == true) {
      return ArchivePlacesResponseModel.fromJson(response).items;
    }

    throw ApiConnectionException(
      _extractErrorMessage(
        response,
        fallbackMessage: 'Не удалось загрузить архив помещений.',
      ),
    );
  }

  @override
  Future<void> restorePlace({required int placeId}) async {
    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final response = await _apiClient.postJson(
          '/admin/places/$placeId/restore',
          body: const <String, dynamic>{},
          headers: _authorizationHeaders(),
        );

        final statusCode = response['statusCode'] as int? ?? 500;
        if (statusCode >= 200 && statusCode < 300 && response['success'] == true) {
          return;
        }

        throw ApiConnectionException(
          _extractErrorMessage(
            response,
            fallbackMessage: 'Не удалось восстановить помещение.',
          ),
        );
      } on ApiConnectionException catch (error) {
        if (attempt == _maxAttempts || !_shouldRetry(error.message)) {
          rethrow;
        }
        await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
      }
    }

    throw const ApiConnectionException('Не удалось восстановить помещение.');
  }

  Map<String, String>? _authorizationHeaders() {
    final token = _appSession.token;
    if (token == null || token.isEmpty) {
      return null;
    }
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
}
