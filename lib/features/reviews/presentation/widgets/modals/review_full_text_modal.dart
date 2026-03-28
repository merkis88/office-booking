import 'package:flutter/material.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/features/reviews/presentation/models/review_item.dart';
import 'package:wordpice/features/reviews/presentation/widgets/styles/reviews_styles.dart';

class ReviewFullTextModal {
  const ReviewFullTextModal._();

  static Future<void> show(BuildContext context, ReviewItem item) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.modalBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.authorName,
                        style: ReviewsStyles.cardTitle.copyWith(fontSize: 18),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black87, width: 1),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 190,
                  child: Divider(height: 1, thickness: 1, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Text(item.text, style: ReviewsStyles.cardText),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
