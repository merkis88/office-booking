import 'package:wordpice/features/reviews/data/datasources/reviews_data_source.dart';
import 'package:wordpice/features/reviews/data/models/create_review_request_model.dart';
import 'package:wordpice/features/reviews/data/models/update_review_request_model.dart';
import 'package:wordpice/features/reviews/domain/entities/create_review_params.dart';
import 'package:wordpice/features/reviews/domain/entities/create_review_result.dart';
import 'package:wordpice/features/reviews/domain/entities/delete_review_result.dart';
import 'package:wordpice/features/reviews/domain/entities/review_item.dart';
import 'package:wordpice/features/reviews/domain/entities/update_review_params.dart';
import 'package:wordpice/features/reviews/domain/entities/update_review_result.dart';
import 'package:wordpice/features/reviews/domain/repositories/reviews_repository.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  const ReviewsRepositoryImpl(this._dataSource);

  final ReviewsDataSource _dataSource;

  @override
  Future<CreateReviewResult> createReview(CreateReviewParams params) async {
    final response = await _dataSource.createReview(
      CreateReviewRequestModel.fromParams(params),
    );
    return response.toEntity();
  }

  @override
  Future<DeleteReviewResult> deleteReview(int reviewId) async {
    final response = await _dataSource.deleteReview(reviewId);
    return response.toEntity();
  }

  @override
  Future<List<ReviewItem>> getReviews({int? rating}) async {
    final response = await _dataSource.getReviews(rating: rating);
    return response.items.map((item) => item.toEntity()).toList();
  }

  @override
  Future<UpdateReviewResult> updateReview(UpdateReviewParams params) async {
    final response = await _dataSource.updateReview(
      params.reviewId,
      UpdateReviewRequestModel.fromParams(params),
    );
    return response.toEntity();
  }
}
