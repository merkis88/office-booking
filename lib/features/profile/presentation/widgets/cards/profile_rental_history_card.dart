import 'package:flutter/material.dart';
import 'package:wordpice/features/profile/domain/entities/rental_history_item.dart';
import 'package:wordpice/features/profile/presentation/widgets/cards/profile_rental_card_layout.dart';

class ProfileRentalHistoryCard extends StatelessWidget {
  const ProfileRentalHistoryCard({
    super.key,
    required this.item,
    required this.onFavoritePressed,
    this.isFavoriteBusy = false,
  });

  final RentalHistoryItem item;
  final Future<void> Function(RentalHistoryItem item) onFavoritePressed;
  final bool isFavoriteBusy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileRentalCardDateLabel(item.dateLabel),
        ProfileRentalCardFrame(
          child: ProfileRentalCardContent(
            title: item.title,
            room: item.room,
            priceLabel: item.priceLabel,
            capacity: item.capacity,
            photoUrl: item.photoUrl,
            timeText: item.timeSlots.isEmpty ? null : item.timeSlots.first,
            statusLabel: item.statusLabel,
            favoriteInitiallyFilled: item.isFavorite,
            onFavoriteTap: () => onFavoritePressed(item),
            isFavoriteBusy: isFavoriteBusy,
          ),
        ),
      ],
    );
  }
}
