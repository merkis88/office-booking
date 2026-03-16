import 'package:wordpice/app/app_session.dart';
import 'package:wordpice/core/network/api_client.dart';
import 'package:wordpice/features/auth/data/datasources/auth_data_source.dart';
import 'package:wordpice/features/notifications/data/datasources/notifications_data_source.dart';
import 'package:wordpice/features/notifications/data/models/notifications_response_model.dart';
import 'package:wordpice/features/notifications/domain/entities/notification_entry.dart';

class NotificationsRemoteDataSource implements NotificationsDataSource {
  NotificationsRemoteDataSource(this._apiClient, this._appSession);

  final ApiClient _apiClient;
  final AppSession _appSession;

  @override
  Future<NotificationsResponseModel> getNotifications({
    int? perPage,
    int? page,
  }) async {
    if (perPage == null && page == null) {
      return _getAllNotifications();
    }

    return _fetchNotificationsPage(perPage: perPage, page: page);
  }

  Future<NotificationsResponseModel> _getAllNotifications() async {
    final firstPage = await _fetchNotificationsPage();
    final effectivePerPage = firstPage.perPage > 0
        ? firstPage.perPage
        : firstPage.items.length;

    if (effectivePerPage <= 0 || firstPage.total <= firstPage.items.length) {
      return firstPage;
    }

    final totalPages = (firstPage.total / effectivePerPage).ceil();
    final allItems = <NotificationEntry>[...firstPage.items];

    for (var currentPage = 2; currentPage <= totalPages; currentPage++) {
      final nextPage = await _fetchNotificationsPage(
        perPage: effectivePerPage,
        page: currentPage,
      );
      allItems.addAll(nextPage.items);
    }

    return NotificationsResponseModel(
      items: allItems,
      currentPage: 1,
      perPage: effectivePerPage,
      total: allItems.length,
    );
  }

  Future<NotificationsResponseModel> _fetchNotificationsPage({
    int? perPage,
    int? page,
  }) async {
    final token = _appSession.token;
    final queryParameters = <String, String>{
      if (perPage != null) 'per_page': '$perPage',
      if (page != null) 'page': '$page',
    };
    final path = queryParameters.isEmpty
        ? '/notifications'
        : '/notifications?${Uri(queryParameters: queryParameters).query}';
    final response = await _apiClient.getJson(
      path,
      headers: token == null || token.isEmpty
          ? null
          : <String, String>{'Authorization': 'Bearer $token'},
    );
    final statusCode = response['statusCode'] as int? ?? 500;

    if (statusCode >= 200 && statusCode < 300) {
      return NotificationsResponseModel.fromJson(response);
    }

    final fieldErrors = _extractFieldErrors(response);
    throw AuthRequestException(
      _extractErrorMessage(response, fieldErrors),
      fieldErrors: fieldErrors,
    );
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    final token = _appSession.token;
    final response = await _apiClient.postJson(
      '/notifications/$notificationId/read',
      body: const <String, dynamic>{},
      headers: token == null || token.isEmpty
          ? null
          : <String, String>{'Authorization': 'Bearer $token'},
    );
    final statusCode = response['statusCode'] as int? ?? 500;

    if (statusCode >= 200 && statusCode < 300 && response['success'] == true) {
      return;
    }

    final fieldErrors = _extractFieldErrors(response);
    throw AuthRequestException(
      _extractErrorMessage(response, fieldErrors),
      fieldErrors: fieldErrors,
    );
  }

  @override
  Future<void> markAllAsRead() async {
    final token = _appSession.token;
    final response = await _apiClient.postJson(
      '/notifications/mark-all-read',
      body: const <String, dynamic>{},
      headers: token == null || token.isEmpty
          ? null
          : <String, String>{'Authorization': 'Bearer $token'},
    );
    final statusCode = response['statusCode'] as int? ?? 500;

    if (statusCode >= 200 && statusCode < 300 && response['success'] == true) {
      return;
    }

    final fieldErrors = _extractFieldErrors(response);
    throw AuthRequestException(
      _extractErrorMessage(response, fieldErrors),
      fieldErrors: fieldErrors,
    );
  }

  @override
  Future<void> deleteNotification(int notificationId) async {
    final token = _appSession.token;
    final response = await _apiClient.deleteJson(
      '/notifications/$notificationId',
      headers: token == null || token.isEmpty
          ? null
          : <String, String>{'Authorization': 'Bearer $token'},
    );
    final statusCode = response['statusCode'] as int? ?? 500;

    if (statusCode >= 200 && statusCode < 300 && response['success'] == true) {
      return;
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
