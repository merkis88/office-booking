import 'package:flutter/material.dart';
import 'package:wordpice/features/profile/domain/entities/rental_history_item.dart';
import 'package:wordpice/features/profile/presentation/widgets/cards/profile_rental_card_layout.dart';

class ProfileFavoriteRentalCard extends StatelessWidget {
  const ProfileFavoriteRentalCard({super.key, required this.item});

  final RentalHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return ProfileRentalCardFrame(
      child: ProfileRentalCardContent(
        title: item.title,
        room: item.room,
        priceLabel: item.priceLabel,
        capacity: item.capacity,
        favoriteInitiallyFilled: item.isFavorite,
      ),
    );
  }
}
