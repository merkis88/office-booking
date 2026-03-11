import 'package:wordpice/features/reviews/domain/entities/update_review_params.dart';

class UpdateReviewRequestModel {
  const UpdateReviewRequestModel({
    required this.text,
    required this.rating,
  });

  final String text;
  final int rating;

  factory UpdateReviewRequestModel.fromParams(UpdateReviewParams params) {
    return UpdateReviewRequestModel(
      text: params.text,
      rating: params.rating,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'text': text, 'rating': rating};
  }
}
