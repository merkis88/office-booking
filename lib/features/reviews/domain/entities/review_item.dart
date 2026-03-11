class ReviewItem {
  const ReviewItem({
    required this.id,
    required this.authorName,
    required this.rating,
    required this.dateText,
    required this.text,
    required this.userId,
    required this.photo,
    required this.isOwnedByCurrentUser,
  });

  final int id;
  final String authorName;
  final int rating;
  final String dateText;
  final String text;
  final int userId;
  final String? photo;
  final bool isOwnedByCurrentUser;
}
