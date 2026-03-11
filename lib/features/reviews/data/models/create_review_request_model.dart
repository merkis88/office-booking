import 'package:wordpice/features/reviews/domain/entities/create_review_params.dart';

class CreateReviewRequestModel {
  const CreateReviewRequestModel({
    required this.text,
    required this.rating,
    required this.userId,
  });

  final String text;
  final int rating;
  final int userId;

  factory CreateReviewRequestModel.fromParams(CreateReviewParams params) {
    return CreateReviewRequestModel(
      text: params.text,
      rating: params.rating,
      userId: params.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'text': text, 'rating': rating, 'user_id': userId};
  }
}
