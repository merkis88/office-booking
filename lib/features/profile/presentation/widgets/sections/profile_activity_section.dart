import 'package:flutter/material.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/core/widgets/states/app_empty_state_text.dart';
import 'package:wordpice/features/profile/domain/entities/rental_history_item.dart';
import 'package:wordpice/features/profile/presentation/models/profile_activity_filter.dart';
import 'package:wordpice/features/profile/presentation/models/profile_request_item.dart';
import 'package:wordpice/features/profile/presentation/widgets/cards/profile_active_rental_card.dart';
import 'package:wordpice/features/profile/presentation/widgets/cards/profile_favorite_rental_card.dart';
import 'package:wordpice/features/profile/presentation/widgets/cards/profile_request_card.dart';
import 'package:wordpice/features/profile/presentation/widgets/cards/profile_rental_history_card.dart';

class ProfileActivitySection extends StatelessWidget {
  const ProfileActivitySection({
    super.key,
    required this.filter,
    required this.activeRentals,
    required this.favoriteRentals,
    required this.rentalHistory,
    required this.requests,
    required this.onCancelRental,
    required this.onFavoriteRental,
    required this.isBookingCancelling,
    required this.isFavoriteBusy,
    required this.onDownloadRequest,
    required this.isRequestDownloading,
  });

  final ProfileActivityFilter filter;
  final List<RentalHistoryItem> activeRentals;
  final List<RentalHistoryItem> favoriteRentals;
  final List<RentalHistoryItem> rentalHistory;
  final List<ProfileRequestItem> requests;
  final Future<void> Function(RentalHistoryItem item) onCancelRental;
  final Future<void> Function(RentalHistoryItem item) onFavoriteRental;
  final bool Function(RentalHistoryItem item) isBookingCancelling;
  final bool Function(RentalHistoryItem item) isFavoriteBusy;
  final Future<void> Function(ProfileRequestItem item) onDownloadRequest;
  final bool Function(ProfileRequestItem item) isRequestDownloading;

  @override
  Widget build(BuildContext context) {
    switch (filter) {
      case ProfileActivityFilter.activeRentals:
        if (activeRentals.isEmpty) {
          return const _ActivityEmptyState(text: 'У вас нет активных аренд');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < activeRentals.length; i++) ...[
              ProfileActiveRentalCard(
                item: activeRentals[i],
                onCancelPressed: onCancelRental,
                onFavoritePressed: onFavoriteRental,
                isCancelling: isBookingCancelling(activeRentals[i]),
                isFavoriteBusy: isFavoriteBusy(activeRentals[i]),
              ),
              if (i != activeRentals.length - 1) const SizedBox(height: 30),
            ],
          ],
        );

      case ProfileActivityFilter.favorites:
        if (favoriteRentals.isEmpty) {
          return const _ActivityEmptyState(text: 'У вас нет избранного');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < favoriteRentals.length; i++) ...[
              ProfileFavoriteRentalCard(item: favoriteRentals[i]),
              if (i != favoriteRentals.length - 1) const SizedBox(height: 30),
            ],
          ],
        );

      case ProfileActivityFilter.rentalHistory:
        if (rentalHistory.isEmpty) {
          return const _ActivityEmptyState(text: 'У вас нет истории аренды');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < rentalHistory.length; i++) ...[
              ProfileRentalHistoryCard(item: rentalHistory[i]),
              if (i != rentalHistory.length - 1) const SizedBox(height: 22),
            ],
          ],
        );

      case ProfileActivityFilter.requests:
        if (requests.isEmpty) {
          return const _ActivityEmptyState(text: 'У вас нет заявок');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < requests.length; i++) ...[
              ProfileRequestCard(
                item: requests[i],
                onDownloadPressed: onDownloadRequest,
                isDownloading: isRequestDownloading(requests[i]),
              ),
              if (i != requests.length - 1) const SizedBox(height: 22),
            ],
          ],
        );
    }
  }
}

class _ActivityEmptyState extends StatelessWidget {
  const _ActivityEmptyState({required this.text});

  static const TextStyle _style = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  final String text;

  @override
  Widget build(BuildContext context) {
    return AppEmptyStateText(text: text, height: 80, style: _style);
  }
}
