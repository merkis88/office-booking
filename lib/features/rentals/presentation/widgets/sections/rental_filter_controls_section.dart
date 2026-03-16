import 'package:flutter/material.dart';
import 'package:wordpice/features/rentals/presentation/widgets/filters/rental_date_filter.dart';
import 'package:wordpice/features/rentals/presentation/widgets/filters/rental_price_range_filter.dart';

class RentalFilterControlsSection extends StatelessWidget {
  const RentalFilterControlsSection({
    super.key,
    required this.dateText,
    required this.onPickDate,
    required this.priceRange,
    required this.minPrice,
    required this.maxPrice,
    required this.onPriceChanged,
    required this.onPriceChangeEnd,
    required this.formatPrice,
    this.dateLeftPadding = 0,
  });

  final String dateText;
  final VoidCallback onPickDate;
  final RangeValues priceRange;
  final double minPrice;
  final double maxPrice;
  final ValueChanged<RangeValues> onPriceChanged;
  final ValueChanged<RangeValues> onPriceChangeEnd;
  final String Function(double value) formatPrice;
  final double dateLeftPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RentalDateFilter(
          leftPadding: dateLeftPadding,
          text: dateText,
          onTap: onPickDate,
        ),
        const SizedBox(height: 20),
        RentalPriceRangeFilter(
          values: priceRange,
          min: minPrice,
          max: maxPrice,
          formatLabel: formatPrice,
          onChanged: onPriceChanged,
          onChangeEnd: onPriceChangeEnd,
        ),
      ],
    );
  }
}
