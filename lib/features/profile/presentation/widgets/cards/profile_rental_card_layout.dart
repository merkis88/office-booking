import 'package:flutter/material.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/core/widgets/buttons/favorite_heart_toggle.dart';
import 'package:wordpice/features/profile/presentation/widgets/styles/profile_card_decorations.dart';
import 'package:wordpice/features/profile/presentation/widgets/styles/profile_card_styles.dart';

class ProfileRentalCardFrame extends StatelessWidget {
  const ProfileRentalCardFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 332),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
        decoration: BoxDecoration(
          color: AppColors.formSurface,
          border: Border.all(
            color: AppColors.bottomNavBackground,
            width: 1.5,
          ),
          borderRadius: ProfileCardDecorations.outlineRadius,
        ),
        child: child,
      ),
    );
  }
}

class ProfileRentalCardDateLabel extends StatelessWidget {
  const ProfileRentalCardDateLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(text, style: ProfileCardStyles.caption),
    );
  }
}

class ProfileRentalCardContent extends StatelessWidget {
  const ProfileRentalCardContent({
    super.key,
    required this.title,
    required this.room,
    required this.priceLabel,
    required this.capacity,
    this.timeText,
    this.favoriteInitiallyFilled = false,
  });

  final String title;
  final String room;
  final String priceLabel;
  final String capacity;
  final String? timeText;
  final bool favoriteInitiallyFilled;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const _RentalThumbnail(),
        const SizedBox(width: 12),
        Expanded(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: FavoriteHeartToggle(
                  initialFilled: favoriteInitiallyFilled,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 34),
                child: _RentalTextColumn(
                  title: title,
                  room: room,
                  priceLabel: priceLabel,
                  capacity: capacity,
                  timeText: timeText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RentalThumbnail extends StatelessWidget {
  const _RentalThumbnail();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: ProfileCardDecorations.outlinedCard(
        color: const Color(0xFFBDBDBD),
      ),
      child: const Icon(Icons.image_outlined, size: 28, color: Colors.white),
    );
  }
}

class _RentalTextColumn extends StatelessWidget {
  const _RentalTextColumn({
    required this.title,
    required this.room,
    required this.priceLabel,
    required this.capacity,
    this.timeText,
  });

  final String title;
  final String room;
  final String priceLabel;
  final String capacity;
  final String? timeText;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _OneLineRentalText(title, style: ProfileCardStyles.rentalText),
        const SizedBox(height: 3),
        _OneLineRentalText(room, style: ProfileCardStyles.rentalText),
        const SizedBox(height: 3),
        if (timeText != null) ...[
          const SizedBox(height: 3),
          _OneLineRentalText(timeText!, style: ProfileCardStyles.rentalText),
        ],
        if (priceLabel.isNotEmpty) ...[
          const SizedBox(height: 3),
          _OneLineRentalText(priceLabel, style: ProfileCardStyles.rentalText),
        ],
        const SizedBox(height: 3),
        _OneLineRentalText(capacity, style: ProfileCardStyles.rentalText),
      ],
    );
  }
}

class _OneLineRentalText extends StatelessWidget {
  const _OneLineRentalText(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        alignment: Alignment.centerLeft,
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          maxLines: 1,
          softWrap: false,
          style: style,
        ),
      ),
    );
  }
}
