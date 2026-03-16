import 'package:flutter/material.dart';
import 'package:wordpice/features/rentals/presentation/widgets/sections/rental_filter_controls_section.dart';
import 'package:wordpice/features/rentals/presentation/widgets/states/rental_empty_rooms_state.dart';

class RentalEmptyResultsSection extends StatelessWidget {
  const RentalEmptyResultsSection({
    super.key,
    required this.dateText,
    required this.onPickDate,
    required this.priceRange,
    required this.minPrice,
    required this.maxPrice,
    required this.onPriceChanged,
    required this.formatPrice,
  });

  final String dateText;
  final VoidCallback onPickDate;
  final RangeValues priceRange;
  final double minPrice;
  final double maxPrice;
  final ValueChanged<RangeValues> onPriceChanged;
  final String Function(double value) formatPrice;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RentalFilterControlsSection(
          dateText: dateText,
          onPickDate: onPickDate,
          priceRange: priceRange,
          minPrice: minPrice,
          maxPrice: maxPrice,
          onPriceChanged: onPriceChanged,
          onPriceChangeEnd: onPriceChanged,
          formatPrice: formatPrice,
        ),
        const SizedBox(height: 220),
        const RentalEmptyRoomsState(),
      ],
    );
  }
}
