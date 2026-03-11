import 'package:wordpice/features/reviews/domain/entities/review_item.dart';

class UpdateReviewResult {
  const UpdateReviewResult({required this.message, required this.review});

  final String message;
  final ReviewItem review;
}
