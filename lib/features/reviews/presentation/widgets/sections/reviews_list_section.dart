import 'package:flutter/material.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/core/widgets/states/app_empty_state_text.dart';
import 'package:wordpice/features/reviews/presentation/models/review_item.dart';
import 'package:wordpice/features/reviews/presentation/widgets/cards/review_card.dart';
import 'package:wordpice/features/reviews/presentation/widgets/styles/reviews_styles.dart';

class ReviewsListSection extends StatelessWidget {
  const ReviewsListSection({
    super.key,
    required this.reviews,
    required this.controller,
    required this.onDeleteReview,
    required this.onEditReview,
    this.deletingReviewId,
  });

  final List<ReviewItem> reviews;
  final PageController controller;
  final ValueChanged<ReviewItem> onDeleteReview;
  final ValueChanged<ReviewItem> onEditReview;
  final int? deletingReviewId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: AppColors.formSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: reviews.isEmpty
          ? const AppEmptyStateText(
              text: 'Отзывы отсутствуют',
              style: ReviewsStyles.emptyState,
            )
          : Padding(
              padding: const EdgeInsets.all(10),
              child: PageView.builder(
                controller: controller,
                scrollDirection: Axis.vertical,
                padEnds: false,
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];

                  return Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      height: 230,
                      child: ReviewCard(
                        item: review,
                        isDeleting: deletingReviewId == review.id,
                        onEdit: review.isOwnedByCurrentUser
                            ? () => onEditReview(review)
                            : null,
                        onDelete: review.isOwnedByCurrentUser
                            ? () => onDeleteReview(review)
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
