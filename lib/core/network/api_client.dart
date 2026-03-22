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

  Future<Map<String, dynamic>> patchJson(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    String? baseUrlOverride,
    Duration? timeoutOverride,
  }) async {
    final response = await _sendPatchRequest(
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
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    String? baseUrlOverride,
    Duration? timeoutOverride,
  }) async {
    final response = await _sendDeleteRequest(
      path,
      body: body,
      headers: headers,
      baseUrlOverride: baseUrlOverride,
      timeoutOverride: timeoutOverride,
    );
    return _decodeResponse(response);
  }

  Future<List<int>> getBytes(
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

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    }

    throw ApiConnectionException(_extractErrorMessage(response));
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

  Future<http.Response> _sendPatchRequest(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    String? baseUrlOverride,
    Duration? timeoutOverride,
  }) async {
    try {
      return await _client
          .patch(
            Uri.parse(_resolveUrl(path, baseUrlOverride: baseUrlOverride)),
            headers: _buildJsonHeaders(headers),
            body: jsonEncode(body),
          )
          .timeout(timeoutOverride ?? AppApiConfig.requestTimeout);
    } on SocketException {
      throw const ApiConnectionException(
        'РЎРµСЂРІРµСЂ РЅРµРґРѕСЃС‚СѓРїРµРЅ. РџСЂРѕРІРµСЂСЊС‚Рµ, С‡С‚Рѕ backend Р·Р°РїСѓС‰РµРЅ Рё Р°РґСЂРµСЃ API СѓРєР°Р·Р°РЅ РІРµСЂРЅРѕ.',
      );
    } on HttpException {
      throw const ApiConnectionException(
        'РќРµ СѓРґР°Р»РѕСЃСЊ РІС‹РїРѕР»РЅРёС‚СЊ Р·Р°РїСЂРѕСЃ Рє СЃРµСЂРІРµСЂСѓ.',
      );
    } on FormatException {
      throw const ApiConnectionException('РЎРµСЂРІРµСЂ РІРµСЂРЅСѓР» РЅРµРєРѕСЂСЂРµРєС‚РЅС‹Р№ РѕС‚РІРµС‚.');
    } on TimeoutException {
      throw const ApiConnectionException(
        'РЎРµСЂРІРµСЂ РЅРµ РѕС‚РІРµС‡Р°РµС‚. РџСЂРѕРІРµСЂСЊС‚Рµ backend Рё РїРѕРІС‚РѕСЂРёС‚Рµ РїРѕРїС‹С‚РєСѓ.',
      );
    }
  }

  Future<http.Response> _sendDeleteRequest(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    String? baseUrlOverride,
    Duration? timeoutOverride,
  }) async {
    try {
      return await _client
          .delete(
            Uri.parse(_resolveUrl(path, baseUrlOverride: baseUrlOverride)),
            headers: body == null
                ? _buildGetHeaders(headers)
                : _buildJsonHeaders(headers),
            body: body == null ? null : jsonEncode(body),
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

  String _extractErrorMessage(http.Response response) {
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final errors = decoded['errors'];
          if (errors is Map) {
            for (final value in errors.values) {
              if (value is List && value.isNotEmpty) {
                return value.first.toString();
              }
            }
          }

          final message = decoded['message']?.toString();
          if (message != null && message.isNotEmpty) {
            return message;
          }
        }
      } on FormatException {
        // Ignore malformed non-JSON error bodies and use fallback below.
      }
    }

    return 'Не удалось выполнить запрос к серверу.';
  }
}
