import 'package:wordpice/app/app_session.dart';
import 'package:wordpice/core/network/api_client.dart';
import 'package:wordpice/features/auth/data/datasources/auth_data_source.dart';
import 'package:wordpice/features/requests/data/datasources/requests_data_source.dart';
import 'package:wordpice/features/requests/data/models/create_request_request_model.dart';
import 'package:wordpice/features/requests/data/models/create_request_response_model.dart';
import 'package:wordpice/features/requests/data/models/request_bookings_response_model.dart';
import 'package:wordpice/features/requests/domain/entities/create_request_params.dart';
import 'package:wordpice/features/requests/domain/entities/create_request_result.dart';
import 'package:wordpice/features/requests/domain/entities/request_booking_option.dart';

class RequestsRemoteDataSource implements RequestsDataSource {
  RequestsRemoteDataSource(this._apiClient, this._appSession);

  final ApiClient _apiClient;
  final AppSession _appSession;

  @override
  Future<List<RequestBookingOption>> getMyBookings() async {
    final token = _appSession.token;
    final response = await _apiClient.getJson(
      '/services/my-bookings',
      headers: token == null || token.isEmpty
          ? null
          : <String, String>{'Authorization': 'Bearer $token'},
    );
    final statusCode = response['statusCode'] as int? ?? 500;

    if (statusCode >= 200 && statusCode < 300 && response['success'] == true) {
      return RequestBookingsResponseModel.fromJson(response).items;
    }

    final fieldErrors = _extractFieldErrors(response);
    throw AuthRequestException(
      _extractErrorMessage(response, fieldErrors),
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

    if (statusCode >= 200 && statusCode < 300 && response['success'] == true) {
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
}
