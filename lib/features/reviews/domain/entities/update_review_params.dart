class UpdateReviewParams {
  const UpdateReviewParams({
    required this.reviewId,
    required this.text,
    required this.rating,
  });

  final int reviewId;
  final String text;
  final int rating;
}
