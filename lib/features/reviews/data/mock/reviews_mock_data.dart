import 'package:wordpice/features/reviews/presentation/models/review_item.dart';

const List<ReviewItem> reviewsMockData = <ReviewItem>[
  ReviewItem(
    id: 1,
    authorName: 'Иван Иванов',
    rating: 5,
    dateText: '12.01.2025',
    text: 'Тестовый отзыв.',
    userId: 1,
    photo: null,
    isOwnedByCurrentUser: false,
  ),
];
