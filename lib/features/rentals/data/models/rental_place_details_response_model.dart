import 'package:wordpice/features/rentals/domain/entities/rental_place_details.dart';

class RentalPlaceDetailsResponseModel {
  const RentalPlaceDetailsResponseModel({required this.data});

  factory RentalPlaceDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    final availability =
        (json['availability'] as Map?)?.cast<String, dynamic>() ?? const {};
    final rawSlots = data['available_slots'];

    final slots = rawSlots is List
        ? rawSlots
              .whereType<Map>()
              .map((slot) => (slot['time'] as String?)?.trim() ?? '')
              .where((slot) => slot.isNotEmpty)
              .toList()
        : const <String>[];

    return RentalPlaceDetailsResponseModel(
      data: RentalPlaceDetails(
        id: (data['id'] as num?)?.toInt() ?? 0,
        name: (data['name'] as String? ?? '').trim(),
        type: (data['type'] as String? ?? '').trim(),
        typeName: (data['type_name'] as String? ?? '').trim(),
        capacity: (data['capacity'] as num?)?.toInt() ?? 0,
        numberPlace: (data['number_place'] as num?)?.toInt() ?? 0,
        price: _parsePrice(data['price']),
        description: (data['description'] as String? ?? '').trim(),
        availableTimeSlots: slots,
        photoUrl: (data['photo_url'] as String?)?.trim(),
        occupancyRate: (data['occupancy_rate'] as num?)?.toDouble(),
        date: availability['date']?.toString(),
      ),
    );
  }

  final RentalPlaceDetails data;

  RentalPlaceDetails toEntity() => data;

  static int _parsePrice(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString().split('.').first ?? '') ?? 0;
  }
}
