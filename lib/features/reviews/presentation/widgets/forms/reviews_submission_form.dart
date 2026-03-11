import 'package:flutter/material.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/features/reviews/presentation/states/review_submission_error_state.dart';
import 'package:wordpice/features/reviews/presentation/widgets/forms/rating_stars_input.dart';
import 'package:wordpice/features/reviews/presentation/widgets/styles/reviews_styles.dart';

class ReviewsSubmissionForm extends StatelessWidget {
  const ReviewsSubmissionForm({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    required this.reviewController,
    required this.onSubmit,
    this.isSubmitting = false,
    this.ratingError,
    this.textError,
    this.submitLabel = 'Отправить',
    this.onCancel,
  });

  final int rating;
  final ValueChanged<int> onRatingChanged;
  final TextEditingController reviewController;
  final VoidCallback onSubmit;
  final bool isSubmitting;
  final String? ratingError;
  final String? textError;
  final String submitLabel;
  final VoidCallback? onCancel;

  bool get _isEditing => onCancel != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 46),
        Text(
          _isEditing
              ? 'Редактирование отзыва*'
              : 'Оцените наш бизнес центр*',
          style: ReviewsStyles.sectionTitle,
        ),
        const SizedBox(height: 10),
        RatingStarsInput(rating: rating, onChanged: onRatingChanged),
        if (ratingError != null) ...[
          const SizedBox(height: 8),
          Text(
            ratingError!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 14),
          ),
        ],
        const SizedBox(height: 34),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Ваш отзыв*', style: ReviewsStyles.fieldLabel),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border.all(
              color: textError == null ? Colors.black87 : Colors.redAccent,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: TextField(
            controller: reviewController,
            maxLines: 5,
            maxLength: ReviewSubmissionErrorState.maxTextLength,
            decoration: const InputDecoration(
              hintText: 'Отзыв',
              hintStyle: ReviewsStyles.inputHint,
              border: InputBorder.none,
              counterText: '',
              contentPadding: EdgeInsets.fromLTRB(14, 12, 14, 12),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: reviewController,
              builder: (context, value, _) {
                return Text(
                  '${value.text.length}/${ReviewSubmissionErrorState.maxTextLength}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                );
              },
            ),
          ],
        ),
        if (textError != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              textError!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 14),
            ),
          ),
        ],
        const SizedBox(height: 20),
        if (onCancel == null)
          SizedBox(
            width: 150,
            height: 42,
            child: OutlinedButton(
              onPressed: isSubmitting ? null : onSubmit,
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.formSurface,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isSubmitting ? 'Отправка...' : submitLabel,
                style: ReviewsStyles.buttonText,
              ),
            ),
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 42,
                child: OutlinedButton(
                  onPressed: isSubmitting ? null : onSubmit,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.formSurface,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isSubmitting ? 'Отправка...' : submitLabel,
                    style: ReviewsStyles.buttonText,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 150,
                height: 42,
                child: OutlinedButton(
                  onPressed: isSubmitting ? null : onCancel,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.formSurface,
                    padding: EdgeInsets.zero,
                    side: const BorderSide(color: Colors.black87, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Отмена', style: ReviewsStyles.buttonText),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
