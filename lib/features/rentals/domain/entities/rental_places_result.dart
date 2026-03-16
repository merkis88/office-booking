import 'package:wordpice/features/rentals/domain/entities/office_rental_item.dart';

class RentalPlacesResult {
  const RentalPlacesResult({
    required this.items,
    required this.minPrice,
    required this.maxPrice,
  });

  final List<OfficeRentalItem> items;
  final int minPrice;
  final int maxPrice;
}
