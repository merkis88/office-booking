import 'package:wordpice/features/reviews/data/models/reviews_response_model.dart';
import 'package:wordpice/features/reviews/domain/entities/create_review_result.dart';

class CreateReviewResponseModel {
  const CreateReviewResponseModel({
    required this.message,
    required this.review,
  });

  final String message;
  final ReviewItemModel review;

  factory CreateReviewResponseModel.fromJson(
    Map<String, dynamic> json, {
    required int? currentUserId,
  }) {
    return CreateReviewResponseModel(
      message: (json['message'] as String?)?.trim() ?? '',
      review: ReviewItemModel.fromJson(
        (json['data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
        currentUserId: currentUserId,
      ),
    );
  }

  CreateReviewResult toEntity() {
    return CreateReviewResult(message: message, review: review.toEntity());
  }
}
