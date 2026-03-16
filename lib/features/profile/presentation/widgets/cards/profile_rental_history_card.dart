import 'package:flutter/material.dart';
import 'package:wordpice/features/profile/domain/entities/rental_history_item.dart';
import 'package:wordpice/features/profile/presentation/widgets/cards/profile_rental_card_layout.dart';

class ProfileRentalHistoryCard extends StatelessWidget {
  const ProfileRentalHistoryCard({super.key, required this.item});

  final RentalHistoryItem item;

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
            capacity: item.capacity,
            timeText: item.timeSlots.isEmpty ? null : item.timeSlots.first,
          ),
        ),
      ],
    );
  }
}
