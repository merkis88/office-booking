import 'package:wordpice/features/reviews/domain/entities/create_review_params.dart';
import 'package:wordpice/features/reviews/domain/entities/create_review_result.dart';
import 'package:wordpice/features/reviews/domain/entities/delete_review_result.dart';
import 'package:wordpice/features/reviews/domain/entities/review_item.dart';
import 'package:wordpice/features/reviews/domain/entities/update_review_params.dart';
import 'package:wordpice/features/reviews/domain/entities/update_review_result.dart';

abstract class ReviewsRepository {
  Future<CreateReviewResult> createReview(CreateReviewParams params);
  Future<DeleteReviewResult> deleteReview(int reviewId);
  Future<List<ReviewItem>> getReviews({int? rating});
  Future<UpdateReviewResult> updateReview(UpdateReviewParams params);
}
