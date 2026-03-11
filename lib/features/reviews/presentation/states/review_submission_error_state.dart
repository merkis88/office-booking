class ReviewSubmissionErrorState {
  const ReviewSubmissionErrorState({
    this.rating,
    this.text,
  });

  static const int maxTextLength = 1000;

  final String? rating;
  final String? text;

  static const empty = ReviewSubmissionErrorState();

  bool get hasErrors => rating != null || text != null;

  factory ReviewSubmissionErrorState.validate({
    required int rating,
    required String text,
  }) {
    final trimmedText = text.trim();

    return ReviewSubmissionErrorState(
      rating: rating <= 0 ? 'Выберите рейтинг звёздами' : null,
      text: trimmedText.isEmpty
          ? 'Напишите текст отзыва'
          : (trimmedText.length > maxTextLength
                ? 'Отзыв не должен превышать 1000 символов'
                : null),
    );
  }
}
