import 'package:wordpice/features/reviews/data/models/reviews_response_model.dart';
import 'package:wordpice/features/reviews/domain/entities/update_review_result.dart';

class UpdateReviewResponseModel {
  const UpdateReviewResponseModel({
    required this.message,
    required this.review,
  });

  final String message;
  final ReviewItemModel review;

  factory UpdateReviewResponseModel.fromJson(
    Map<String, dynamic> json, {
    required int? currentUserId,
  }) {
    return UpdateReviewResponseModel(
      message: (json['message'] as String?)?.trim() ?? '',
      review: ReviewItemModel.fromJson(
        (json['data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
        currentUserId: currentUserId,
      ),
    );
  }

  UpdateReviewResult toEntity() {
    return UpdateReviewResult(message: message, review: review.toEntity());
  }
}
