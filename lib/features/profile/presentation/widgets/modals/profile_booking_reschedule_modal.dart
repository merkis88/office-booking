import 'package:flutter/material.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/features/rentals/presentation/widgets/styles/rental_widget_styles.dart';

class ProfileBookingRescheduleModal extends StatelessWidget {
  const ProfileBookingRescheduleModal({
    super.key,
    required this.title,
    required this.dateLabel,
    required this.availableSlots,
  });

  final String title;
  final String dateLabel;
  final List<String> availableSlots;

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String dateLabel,
    required List<String> availableSlots,
  }) {
    return showDialog<String>(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => ProfileBookingRescheduleModal(
        title: title,
        dateLabel: dateLabel,
        availableSlots: availableSlots,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.modalBackground,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _BackButton(onTap: () => Navigator.of(context).pop()),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Перенос брони',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 42),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Выберите пожалуйста свободное\nвремя',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 22),
              if (availableSlots.isEmpty)
                const Text(
                  'Нет доступных слотов для переноса.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                )
              else
                Column(
                  children: [
                    for (var i = 0; i < availableSlots.length; i++) ...[
                      SizedBox(
                        width: 190,
                        child: _SlotButton(
                          text: availableSlots[i],
                          onTap: () => Navigator.of(context).pop(availableSlots[i]),
                        ),
                      ),
                      if (i != availableSlots.length - 1)
                        const SizedBox(height: 10),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.chevron_left_rounded,
          size: 24,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _SlotButton extends StatelessWidget {
  const _SlotButton({
    required this.text,
    required this.onTap,
  });

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 35,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: RentalWidgetStyles.outlinedBox(
            8,
            color: AppColors.formSurface,
          ),
          child: Text(
            text,
            style: RentalWidgetStyles.chipText,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
