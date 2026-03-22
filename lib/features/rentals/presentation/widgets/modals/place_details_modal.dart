import 'package:flutter/material.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/features/rentals/domain/entities/rental_place_details.dart';
import 'package:wordpice/features/rentals/presentation/widgets/styles/rental_widget_styles.dart';

class PlaceDetailsModal {
  PlaceDetailsModal._();

  static Future<void> show(
    BuildContext context, {
    required RentalPlaceDetails details,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      builder: (context) {
        final hasPhoto =
            details.photoUrl != null && details.photoUrl!.trim().isNotEmpty;

        return Dialog(
          backgroundColor: AppColors.bottomNavBackground,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(
              color: AppColors.bottomNavBackground,
              width: 1.5,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 42),
                      child: Text(
                        details.name.isNotEmpty ? details.name : 'Помещение',
                        style: RentalWidgetStyles.cardText.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (hasPhoto)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          details.photoUrl!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                    if (hasPhoto) const SizedBox(height: 12),
                    _DetailLine(
                      'Тип помещения',
                      details.typeName.isNotEmpty
                          ? details.typeName
                          : _mapType(details.type),
                    ),
                    _DetailLine(
                      'Кабинет №',
                      details.numberPlace > 0
                          ? details.numberPlace.toString()
                          : 'Не указан',
                    ),
                    _DetailLine('Стоимость', '${details.price}р/час'),
                    _DetailLine(
                      'Вместимость',
                      '${details.capacity} человек',
                    ),
                    if (details.description.isNotEmpty)
                      _DetailLine('Описание', details.description),
                    if (details.date != null && details.date!.isNotEmpty)
                      _DetailLine('Дата', details.date!),
                  ],
                ),
              ),
              Positioned(
                top: -6,
                right: -6,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black87, width: 2),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 25,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _mapType(String type) {
    switch (type) {
      case 'meeting':
      case 'meeting_room':
        return 'Переговорная';
      case 'coworking':
        return 'Коворкинг';
      case 'office':
        return 'Офис';
      default:
        return type.isEmpty ? 'Помещение' : type;
    }
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
