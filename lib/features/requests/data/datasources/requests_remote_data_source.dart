import 'package:wordpice/app/app_session.dart';
import 'package:wordpice/core/config/app_api_config.dart';
import 'package:wordpice/core/network/api_client.dart';
import 'package:wordpice/features/auth/data/datasources/auth_data_source.dart';
import 'package:wordpice/features/requests/data/datasources/requests_data_source.dart';
import 'package:wordpice/features/requests/data/models/create_request_request_model.dart';
import 'package:wordpice/features/requests/data/models/create_request_response_model.dart';
import 'package:wordpice/features/requests/data/models/request_service_types_response_model.dart';
import 'package:wordpice/features/requests/domain/entities/create_request_params.dart';
import 'package:wordpice/features/requests/domain/entities/create_request_result.dart';
import 'package:wordpice/features/requests/domain/entities/request_booking_option.dart';
import 'package:wordpice/features/requests/domain/entities/request_service_type.dart';

class RequestsRemoteDataSource implements RequestsDataSource {
  RequestsRemoteDataSource(this._apiClient, this._appSession);

  final ApiClient _apiClient;
  final AppSession _appSession;

  @override
  Future<List<RequestBookingOption>> getMyBookings() async {
    final token = _appSession.token;
    final response = await _apiClient.getJson(
      '/bookings/my?sort=-start_time&per_page=100&page=1',
      headers: token == null || token.isEmpty
          ? null
          : <String, String>{'Authorization': 'Bearer $token'},
      baseUrlOverride: AppApiConfig.bookingsBaseUrl,
    );
    final statusCode = response['statusCode'] as int? ?? 500;

    if (statusCode >= 200 && statusCode < 300) {
      return _mapBookingOptions(response);
    }

    final fieldErrors = _extractFieldErrors(response);
    throw AuthRequestException(
      _extractErrorMessage(response, fieldErrors),
      fieldErrors: fieldErrors,
    );
  }

  @override
  Future<List<RequestServiceType>> getServiceTypes() async {
    final token = _appSession.token;
    final response = await _apiClient.getJson(
      '/service-types',
      headers: token == null || token.isEmpty
          ? null
          : <String, String>{'Authorization': 'Bearer $token'},
    );
    final statusCode = response['statusCode'] as int? ?? 500;

    if (statusCode >= 200 && statusCode < 300 && response['success'] == true) {
      return RequestServiceTypesResponseModel.fromJson(response).items;
    }

    final fieldErrors = _extractFieldErrors(response);
    throw AuthRequestException(
      _extractErrorMessage(
        response,
        fieldErrors,
        fallbackMessage: 'Не удалось загрузить типы заявок.',
      ),
      fieldErrors: fieldErrors,
    );
  }

  @override
  Future<CreateRequestResult> createRequest(CreateRequestParams params) async {
    final token = _appSession.token;
    final request = CreateRequestRequestModel.fromParams(params);
    final response = await _apiClient.postJson(
      '/services',
      body: request.toJson(),
      headers: token == null || token.isEmpty
          ? null
          : <String, String>{'Authorization': 'Bearer $token'},
    );
    final statusCode = response['statusCode'] as int? ?? 500;

    if (statusCode >= 200 && statusCode < 300) {
      return CreateRequestResponseModel.fromJson(response).toEntity();
    }

    final fieldErrors = _extractFieldErrors(response);
    throw AuthRequestException(
      _extractErrorMessage(
        response,
        fieldErrors,
        fallbackMessage: 'Не удалось создать заявку.',
      ),
      fieldErrors: fieldErrors,
    );
  }

  Map<String, String> _extractFieldErrors(Map<String, dynamic> response) {
    final errors = response['errors'];
    if (errors is! Map) return const <String, String>{};

    return errors.map((key, value) {
      if (value is List && value.isNotEmpty) {
        return MapEntry(key.toString(), value.first.toString());
      }
      return MapEntry(key.toString(), value.toString());
    });
  }

  String _extractErrorMessage(
    Map<String, dynamic> response,
    Map<String, String> fieldErrors, {
    String fallbackMessage = 'Не удалось загрузить бронирования.',
  }) {
    if (fieldErrors.isNotEmpty) {
      final firstError = fieldErrors.values.first;
      if (firstError.isNotEmpty) {
        return firstError;
      }
    }

    final message = response['message']?.toString().trim();
    if (message != null && message.isNotEmpty) {
      return message;
    }

    return fallbackMessage;
  }

  List<RequestBookingOption> _mapBookingOptions(Map<String, dynamic> response) {
    final rawData = response['data'];
    if (rawData is! List) {
      return const <RequestBookingOption>[];
    }

    return rawData
        .whereType<Map>()
        .map((item) => _mapBookingItem(item.cast<String, dynamic>()))
        .whereType<RequestBookingOption>()
        .toList();
  }

  RequestBookingOption? _mapBookingItem(Map<String, dynamic> item) {
    final status = (item['status'] as String? ?? '').trim().toLowerCase();
    if (status != 'active' && status != 'pending') {
      return null;
    }

    final bookingId = (item['id'] as num?)?.toInt();
    final startTime = DateTime.tryParse(item['start_time']?.toString() ?? '');
    final endTime = DateTime.tryParse(item['end_time']?.toString() ?? '');
    final place = (item['place'] as Map?)?.cast<String, dynamic>() ?? const {};
    final placeType = (place['type'] as String? ?? '').trim().toLowerCase();
    final placeNumber = (place['number_place'] as num?)?.toInt();

    if (bookingId == null || startTime == null || endTime == null) {
      return null;
    }

    final localStart = startTime.toUtc().add(const Duration(hours: 7));
    final localEnd = endTime.toUtc().add(const Duration(hours: 7));
    final dateLabel = _formatDateLabel(localStart);
    final timeLabel = _formatTimeRange(localStart, localEnd);
    final serviceDate =
        '${localStart.year.toString().padLeft(4, '0')}-'
        '${localStart.month.toString().padLeft(2, '0')}-'
        '${localStart.day.toString().padLeft(2, '0')}';

    return RequestBookingOption(
      id: bookingId,
      placeName: _mapPlaceName(placeType, placeNumber),
      dateLabel: dateLabel,
      timeLabel: timeLabel,
      serviceDate: serviceDate,
      timeSlots: _buildTimeSlots(localStart, localEnd),
    );
  }

  String _mapPlaceName(String type, int? number) {
    final suffix = number != null && number > 0 ? ' №$number' : '';
    switch (type) {
      case 'meeting_room':
      case 'meeting':
        return 'Переговорная$suffix';
      case 'office':
        return 'Офис$suffix';
      case 'coworking':
        return 'Коворкинг$suffix';
      default:
        return 'Бронирование$suffix';
    }
  }

  String _formatDateLabel(DateTime value) {
    const months = <String>[
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];

    return '${value.day} ${months[value.month - 1]}';
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    String format(DateTime value) {
      final hour = value.hour.toString().padLeft(2, '0');
      final minute = value.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    return '${format(start)} - ${format(end)}';
  }

  List<String> _buildTimeSlots(DateTime start, DateTime end) {
    final slots = <String>[];
    var current = start;

    while (current.isBefore(end)) {
      final next = current.add(const Duration(hours: 1));
      if (next.isAfter(end)) {
        break;
      }
      slots.add(_formatTimeRange(current, next));
      current = next;
    }

    return slots.isEmpty ? <String>[_formatTimeRange(start, end)] : slots;
  }
}
