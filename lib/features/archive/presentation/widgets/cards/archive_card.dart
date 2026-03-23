import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/features/archive/presentation/models/archive_item.dart';
import 'package:wordpice/features/archive/presentation/widgets/styles/archive_styles.dart';

class ArchiveCard extends StatelessWidget {
  const ArchiveCard({
    super.key,
    required this.item,
    required this.onDetailsTap,
    required this.onRestoreTap,
    required this.isRestoring,
  });

  final ArchiveItem item;
  final VoidCallback onDetailsTap;
  final VoidCallback onRestoreTap;
  final bool isRestoring;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = item.photoUrl != null && item.photoUrl!.trim().isNotEmpty;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 332),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
          decoration: ArchiveStyles.outlinedBox(
            12,
            color: AppColors.formSurface,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFBDBDBD),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.bottomNavBackground,
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: hasPhoto
                      ? Image.network(
                          item.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const _PhotoPlaceholder(),
                        )
                      : const _PhotoPlaceholder(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: _ArchivedBadgeIcon(
                        onTap: onRestoreTap,
                        isLoading: isRestoring,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 34),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: ArchiveStyles.cardText),
                          const SizedBox(height: 3),
                          Text(item.room, style: ArchiveStyles.cardText),
                          const SizedBox(height: 3),
                          Text(
                            'Стоимость: ${item.price}р/час',
                            style: ArchiveStyles.cardText,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Вместимость: ${item.capacity} человек',
                            style: ArchiveStyles.cardText,
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: onDetailsTap,
                            child: Text(
                              'Подробнее',
                              style: ArchiveStyles.cardText.copyWith(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArchivedBadgeIcon extends StatelessWidget {
  const _ArchivedBadgeIcon({
    required this.onTap,
    required this.isLoading,
  });

  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 24,
        height: 24,
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(2),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/nav_archive.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Colors.black87,
                      BlendMode.srcIn,
                    ),
                  ),
                  const CustomPaint(
                    size: Size(24, 24),
                    painter: _ArchiveSlashPainter(),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ArchiveSlashPainter extends CustomPainter {
  const _ArchiveSlashPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1;
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.image_outlined,
      size: 28,
      color: Colors.white,
    );
  }
}
