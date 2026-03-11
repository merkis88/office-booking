import 'package:wordpice/features/reviews/data/models/create_review_request_model.dart';
import 'package:wordpice/features/reviews/data/models/create_review_response_model.dart';
import 'package:wordpice/features/reviews/data/models/delete_review_response_model.dart';
import 'package:wordpice/features/reviews/data/models/reviews_response_model.dart';
import 'package:wordpice/features/reviews/data/models/update_review_request_model.dart';
import 'package:wordpice/features/reviews/data/models/update_review_response_model.dart';

abstract class ReviewsDataSource {
  Future<CreateReviewResponseModel> createReview(
    CreateReviewRequestModel request,
  );
  Future<DeleteReviewResponseModel> deleteReview(int reviewId);
  Future<ReviewsResponseModel> getReviews({int? rating});
  Future<UpdateReviewResponseModel> updateReview(
    int reviewId,
    UpdateReviewRequestModel request,
  );
}
