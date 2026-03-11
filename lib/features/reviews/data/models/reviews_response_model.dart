import 'package:wordpice/features/reviews/domain/entities/review_item.dart';

class ReviewsResponseModel {
  const ReviewsResponseModel({required this.items});

  final List<ReviewItemModel> items;

  factory ReviewsResponseModel.fromJson(
    Map<String, dynamic> json, {
    required int? currentUserId,
  }) {
    final rawItems = json['data'];
    if (rawItems is! List) {
      return const ReviewsResponseModel(items: <ReviewItemModel>[]);
    }

    return ReviewsResponseModel(
      items: rawItems
          .whereType<Map>()
          .map(
            (item) => ReviewItemModel.fromJson(
              item.cast<String, dynamic>(),
              currentUserId: currentUserId,
            ),
          )
          .toList(),
    );
  }
}

class ReviewItemModel {
  const ReviewItemModel({
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

  factory ReviewItemModel.fromJson(
    Map<String, dynamic> json, {
    required int? currentUserId,
  }) {
    final user = (json['user'] as Map?)?.cast<String, dynamic>() ?? const {};
    final firstName = (user['first_name'] as String?)?.trim() ?? '';
    final lastName = (user['last_name'] as String?)?.trim() ?? '';
    final userId = (json['user_id'] as num?)?.toInt() ?? 0;
    final authorName = <String>[
      firstName,
      lastName,
    ].where((part) => part.isNotEmpty).join(' ').trim();

    return ReviewItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      authorName: authorName.isEmpty ? 'Пользователь' : authorName,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      dateText: (json['created_at'] as String?)?.trim() ?? '',
      text: (json['text'] as String?)?.trim() ?? '',
      userId: userId,
      photo: user['photo'] as String?,
      isOwnedByCurrentUser: currentUserId != null && currentUserId == userId,
    );
  }

  ReviewItem toEntity() {
    return ReviewItem(
      id: id,
      authorName: authorName,
      rating: rating,
      dateText: dateText,
      text: text,
      userId: userId,
      photo: photo,
      isOwnedByCurrentUser: isOwnedByCurrentUser,
    );
  }
}
