import 'dart:async';

import 'package:wordpice/app/app_session.dart';
import 'package:wordpice/core/network/api_client.dart';
import 'package:wordpice/features/reviews/data/datasources/reviews_data_source.dart';
import 'package:wordpice/features/reviews/data/models/create_review_request_model.dart';
import 'package:wordpice/features/reviews/data/models/create_review_response_model.dart';
import 'package:wordpice/features/reviews/data/models/delete_review_response_model.dart';
import 'package:wordpice/features/reviews/data/models/reviews_response_model.dart';
import 'package:wordpice/features/reviews/data/models/update_review_request_model.dart';
import 'package:wordpice/features/reviews/data/models/update_review_response_model.dart';

class ReviewsRemoteDataSource implements ReviewsDataSource {
  ReviewsRemoteDataSource(this._apiClient, this._appSession);

  static const int _maxAttempts = 3;

  final ApiClient _apiClient;
  final AppSession _appSession;

  @override
  Future<CreateReviewResponseModel> createReview(
    CreateReviewRequestModel request,
  ) async {
    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final token = _appSession.token;
        final response = await _apiClient.postJson(
          '/reviews',
          body: request.toJson(),
          headers: token == null || token.isEmpty
              ? null
              : <String, String>{'Authorization': 'Bearer $token'},
        );
        final statusCode = response['statusCode'] as int? ?? 500;

        if (statusCode >= 200 && statusCode < 300) {
          return CreateReviewResponseModel.fromJson(
            response,
            currentUserId: _appSession.currentUser?.id,
          );
        }

        final message = (response['message'] as String?)?.trim();
        throw ApiConnectionException(
          message != null && message.isNotEmpty
              ? message
              : 'Не удалось добавить отзыв.',
        );
      } on ApiConnectionException catch (error) {
        if (attempt == _maxAttempts || !_shouldRetry(error.message)) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
      }
    }

    throw const ApiConnectionException('Не удалось добавить отзыв.');
  }

  @override
  Future<DeleteReviewResponseModel> deleteReview(int reviewId) async {
    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final token = _appSession.token;
        final response = await _apiClient.deleteJson(
          '/reviews/$reviewId',
          headers: token == null || token.isEmpty
              ? null
              : <String, String>{'Authorization': 'Bearer $token'},
        );
        final statusCode = response['statusCode'] as int? ?? 500;

        if (statusCode >= 200 && statusCode < 300) {
          return DeleteReviewResponseModel.fromJson(response);
        }

        final message = (response['message'] as String?)?.trim();
        throw ApiConnectionException(
          message != null && message.isNotEmpty
              ? message
              : 'Не удалось удалить отзыв.',
        );
      } on ApiConnectionException catch (error) {
        if (attempt == _maxAttempts || !_shouldRetry(error.message)) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
      }
    }

    throw const ApiConnectionException('Не удалось удалить отзыв.');
  }

  @override
  Future<ReviewsResponseModel> getReviews({int? rating}) async {
    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final token = _appSession.token;
        final response = await _apiClient.getJson(
          '/reviews?rating=${rating ?? ''}',
          headers: token == null || token.isEmpty
              ? null
              : <String, String>{'Authorization': 'Bearer $token'},
        );
        final statusCode = response['statusCode'] as int? ?? 500;

        if (statusCode >= 200 && statusCode < 300) {
          return ReviewsResponseModel.fromJson(
            response,
            currentUserId: _appSession.currentUser?.id,
          );
        }

        final message = (response['message'] as String?)?.trim();
        throw ApiConnectionException(
          message != null && message.isNotEmpty
              ? message
              : 'Не удалось загрузить отзывы.',
        );
      } on ApiConnectionException catch (error) {
        if (attempt == _maxAttempts || !_shouldRetry(error.message)) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
      }
    }

    throw const ApiConnectionException('Не удалось загрузить отзывы.');
  }

  @override
  Future<UpdateReviewResponseModel> updateReview(
    int reviewId,
    UpdateReviewRequestModel request,
  ) async {
    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final token = _appSession.token;
        final response = await _apiClient.putJson(
          '/reviews/$reviewId',
          body: request.toJson(),
          headers: token == null || token.isEmpty
              ? null
              : <String, String>{'Authorization': 'Bearer $token'},
        );
        final statusCode = response['statusCode'] as int? ?? 500;

        if (statusCode >= 200 && statusCode < 300) {
          return UpdateReviewResponseModel.fromJson(
            response,
            currentUserId: _appSession.currentUser?.id,
          );
        }

        final message = (response['message'] as String?)?.trim();
        throw ApiConnectionException(
          message != null && message.isNotEmpty
              ? message
              : 'Не удалось обновить отзыв.',
        );
      } on ApiConnectionException catch (error) {
        if (attempt == _maxAttempts || !_shouldRetry(error.message)) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
      }
    }

    throw const ApiConnectionException('Не удалось обновить отзыв.');
  }

  bool _shouldRetry(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('сервер') ||
        normalized.contains('запрос') ||
        normalized.contains('ответ') ||
        normalized.contains('timeout');
  }
}
