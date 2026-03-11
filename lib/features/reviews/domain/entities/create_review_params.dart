class CreateReviewParams {
  const CreateReviewParams({
    required this.text,
    required this.rating,
    required this.userId,
  });

  final String text;
  final int rating;
  final int userId;
}
