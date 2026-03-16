import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:wordpice/core/config/app_api_config.dart';

class ApiConnectionException implements Exception {
  const ApiConnectionException(this.message);

  final String message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? headers,
    String? baseUrlOverride,
    Duration? timeoutOverride,
  }) async {
    final response = await _sendGetRequest(
      path,
      headers: headers,
      baseUrlOverride: baseUrlOverride,
      timeoutOverride: timeoutOverride,
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    String? baseUrlOverride,
    Duration? timeoutOverride,
  }) async {
    final response = await _sendPostRequest(
      path,
      body: body,
      headers: headers,
      baseUrlOverride: baseUrlOverride,
      timeoutOverride: timeoutOverride,
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    String? baseUrlOverride,
    Duration? timeoutOverride,
  }) async {
    final response = await _sendPutRequest(
      path,
      body: body,
      headers: headers,
      baseUrlOverride: baseUrlOverride,
      timeoutOverride: timeoutOverride,
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> deleteJson(
    String path, {
    Map<String, String>? headers,
    String? baseUrlOverride,
    Duration? timeoutOverride,
  }) async {
    final response = await _sendDeleteRequest(
      path,
      headers: headers,
      baseUrlOverride: baseUrlOverride,
      timeoutOverride: timeoutOverride,
    );
    return _decodeResponse(response);
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final dynamic decoded;
    if (response.body.isEmpty) {
      decoded = <String, dynamic>{};
    } else {
      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        return <String, dynamic>{
          'statusCode': response.statusCode,
          'message':
              'Сервер вернул некорректный ответ. Проверьте адрес API и формат ответа.',
        };
      }
    }

    if (decoded is Map<String, dynamic>) {
      return <String, dynamic>{'statusCode': response.statusCode, ...decoded};
    }

    return <String, dynamic>{
      'statusCode': response.statusCode,
      'message': 'Некорректный ответ сервера',
    };
  }

  Future<http.Response> _sendPostRequest(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    String? baseUrlOverride,
    Duration? timeoutOverride,
  }) async {
    try {
      return await _client
          .post(
            Uri.parse(_resolveUrl(path, baseUrlOverride: baseUrlOverride)),
            headers: _buildJsonHeaders(headers),
            body: jsonEncode(body),
          )
          .timeout(timeoutOverride ?? AppApiConfig.requestTimeout);
    } on SocketException {
      throw const ApiConnectionException(
        'Сервер недоступен. Проверьте, что backend запущен и адрес API указан верно.',
      );
    } on HttpException {
      throw const ApiConnectionException(
        'Не удалось выполнить запрос к серверу.',
      );
    } on FormatException {
      throw const ApiConnectionException('Сервер вернул некорректный ответ.');
    } on TimeoutException {
      throw const ApiConnectionException(
        'Сервер не отвечает. Проверьте backend и повторите попытку.',
      );
    }
  }

  Future<http.Response> _sendPutRequest(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    String? baseUrlOverride,
    Duration? timeoutOverride,
  }) async {
    try {
      return await _client
          .put(
            Uri.parse(_resolveUrl(path, baseUrlOverride: baseUrlOverride)),
            headers: _buildJsonHeaders(headers),
            body: jsonEncode(body),
          )
          .timeout(timeoutOverride ?? AppApiConfig.requestTimeout);
    } on SocketException {
      throw const ApiConnectionException(
        'Сервер недоступен. Проверьте, что backend запущен и адрес API указан верно.',
      );
    } on HttpException {
      throw const ApiConnectionException(
        'Не удалось выполнить запрос к серверу.',
      );
    } on FormatException {
      throw const ApiConnectionException('Сервер вернул некорректный ответ.');
    } on TimeoutException {
      throw const ApiConnectionException(
        'Сервер не отвечает. Проверьте backend и повторите попытку.',
      );
    }
  }

  Future<http.Response> _sendGetRequest(
    String path, {
    Map<String, String>? headers,
    String? baseUrlOverride,
    Duration? timeoutOverride,
  }) async {
    try {
      return await _client
          .get(
            Uri.parse(_resolveUrl(path, baseUrlOverride: baseUrlOverride)),
            headers: _buildGetHeaders(headers),
          )
          .timeout(timeoutOverride ?? AppApiConfig.requestTimeout);
    } on SocketException {
      throw const ApiConnectionException(
        'Сервер недоступен. Проверьте, что backend запущен и адрес API указан верно.',
      );
    } on HttpException {
      throw const ApiConnectionException(
        'Не удалось выполнить запрос к серверу.',
      );
    } on FormatException {
      throw const ApiConnectionException('Сервер вернул некорректный ответ.');
    } on TimeoutException {
      throw const ApiConnectionException(
        'Сервер не отвечает. Проверьте backend и повторите попытку.',
      );
    }
  }

  Future<http.Response> _sendDeleteRequest(
    String path, {
    Map<String, String>? headers,
    String? baseUrlOverride,
    Duration? timeoutOverride,
  }) async {
    try {
      return await _client
          .delete(
            Uri.parse(_resolveUrl(path, baseUrlOverride: baseUrlOverride)),
            headers: _buildGetHeaders(headers),
          )
          .timeout(timeoutOverride ?? AppApiConfig.requestTimeout);
    } on SocketException {
      throw const ApiConnectionException(
        'Сервер недоступен. Проверьте, что backend запущен и адрес API указан верно.',
      );
    } on HttpException {
      throw const ApiConnectionException(
        'Не удалось выполнить запрос к серверу.',
      );
    } on FormatException {
      throw const ApiConnectionException('Сервер вернул некорректный ответ.');
    } on TimeoutException {
      throw const ApiConnectionException(
        'Сервер не отвечает. Проверьте backend и повторите попытку.',
      );
    }
  }

  Map<String, String> _buildGetHeaders(Map<String, String>? headers) {
    return <String, String>{'Accept': 'application/json', ...?headers};
  }

  Map<String, String> _buildJsonHeaders(Map<String, String>? headers) {
    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    };
  }

  String _resolveUrl(String path, {String? baseUrlOverride}) {
    final baseUrl = baseUrlOverride ?? AppApiConfig.baseUrl;
    return '$baseUrl$path';
  }
}
