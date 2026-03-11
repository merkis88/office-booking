import 'package:wordpice/features/reviews/domain/entities/delete_review_result.dart';

class DeleteReviewResponseModel {
  const DeleteReviewResponseModel({required this.message});

  final String message;

  factory DeleteReviewResponseModel.fromJson(Map<String, dynamic> json) {
    return DeleteReviewResponseModel(
      message: (json['message'] as String?)?.trim() ?? '',
    );
  }

  DeleteReviewResult toEntity() {
    return DeleteReviewResult(message: message);
  }
}
