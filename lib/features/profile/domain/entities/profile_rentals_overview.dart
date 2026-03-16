import 'package:wordpice/features/profile/domain/entities/rental_history_item.dart';

class ProfileRentalsOverview {
  const ProfileRentalsOverview({
    required this.activeRentals,
    required this.rentalHistory,
  });

  final List<RentalHistoryItem> activeRentals;
  final List<RentalHistoryItem> rentalHistory;
}
