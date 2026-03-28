import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wordpice/features/reviews/presentation/models/review_item.dart';
import 'package:wordpice/features/reviews/presentation/widgets/modals/review_full_text_modal.dart';
import 'package:wordpice/features/reviews/presentation/widgets/styles/reviews_styles.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.item,
    this.onDelete,
    this.onEdit,
    this.isDeleting = false,
  });

  final ReviewItem item;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final bool isDeleting;

  bool get _needsReadMore => item.text.length > 140;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 74),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.authorName, style: ReviewsStyles.cardTitle),
                    const SizedBox(height: 3),
                    const SizedBox(
                      width: 250,
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            final filled = index < item.rating;
                            return Icon(
                              Icons.star,
                              size: 26,
                              color: filled
                                  ? ReviewsStyles.starActive
                                  : ReviewsStyles.starInactive,
                              shadows: const [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 3,
                                  offset: Offset(0, 1.5),
                                ),
                              ],
                            );
                          }),
                        ),
                        const SizedBox(width: 10),
                        Text(item.dateText, style: ReviewsStyles.cardDate),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.text,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: ReviewsStyles.cardText,
              ),
              if (_needsReadMore) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => ReviewFullTextModal.show(context, item),
                  child: const Text(
                    'Читать полностью',
                    style: ReviewsStyles.readMore,
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
        if (onEdit != null || onDelete != null)
          Positioned(
            right: 2,
            bottom: 2,
            child: Row(
              children: [
                if (onEdit != null) ...[
                  GestureDetector(
                    onTap: isDeleting ? null : onEdit,
                    child: Opacity(
                      opacity: isDeleting ? 0.45 : 1,
                      child: SvgPicture.asset(
                        'assets/icons/edit-2.svg',
                        width: 25,
                        height: 25,
                        colorFilter: const ColorFilter.mode(
                          Colors.black54,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                GestureDetector(
                  onTap: isDeleting ? null : onDelete,
                  child: Opacity(
                    opacity: isDeleting ? 0.45 : 1,
                    child: SvgPicture.asset(
                      'assets/icons/delete.svg',
                      width: 25,
                      height: 25,
                      colorFilter: const ColorFilter.mode(
                        Colors.black54,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Positioned(top: 0, right: 0, child: _ReviewAvatar(photo: item.photo)),
      ],
    );
  }
}

class _ReviewAvatar extends StatelessWidget {
  const _ReviewAvatar({this.photo});

  final String? photo;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photo != null && photo!.trim().isNotEmpty;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black54, width: 1),
      ),
      child: ClipOval(
        child: hasPhoto
            ? Image.network(
                photo!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const _AvatarPlaceholder(),
              )
            : const _AvatarPlaceholder(),
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Container(color: const Color(0xFFF4F4F4))),
        Positioned(
          top: 12,
          left: 20,
          right: 20,
          child: Container(
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF8A8F99),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: 10,
          right: 10,
          bottom: 0,
          child: Container(
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFF8A8F99),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
          ),
        ),
      ],
    );
  }
}
