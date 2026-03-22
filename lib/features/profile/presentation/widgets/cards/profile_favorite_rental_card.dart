import 'package:flutter/material.dart';
import 'package:wordpice/features/profile/presentation/models/rental_history_item.dart';
import 'package:wordpice/features/profile/presentation/widgets/cards/profile_rental_card_layout.dart';
import 'package:wordpice/features/profile/presentation/widgets/styles/profile_card_styles.dart';

class ProfileFavoriteRentalCard extends StatelessWidget {
  const ProfileFavoriteRentalCard({super.key, required this.item});

  final RentalHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final priceText = item.priceLabel.split('/').first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileRentalCardFrame(
          child: ProfileRentalCardContent(
            title: item.title,
            room: item.room,
            priceLabel: item.priceLabel,
            capacity: item.capacity,
            favoriteInitiallyFilled: true,
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Text(priceText, style: ProfileCardStyles.trailingPrice),
        ),
      ],
    );
  }
}
