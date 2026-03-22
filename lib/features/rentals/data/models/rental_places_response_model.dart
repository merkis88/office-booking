import 'package:wordpice/core/config/app_api_config.dart';
import 'package:wordpice/features/rentals/domain/entities/office_rental_item.dart';
import 'package:wordpice/features/rentals/domain/entities/rental_places_result.dart';
import 'package:wordpice/features/rentals/presentation/utils/rental_date_text_helper.dart';
import 'package:wordpice/features/rentals/presentation/utils/rental_time_slots_helper.dart';

class RentalPlacesResponseModel {
  const RentalPlacesResponseModel({
    required this.items,
    required this.minPrice,
    required this.maxPrice,
  });

  final List<RentalPlaceItemModel> items;
  final int minPrice;
  final int maxPrice;

  factory RentalPlacesResponseModel.fromJson(Map<String, dynamic> json) {
    final filters =
        (json['filters'] as Map?)?.cast<String, dynamic>() ?? const {};
    final priceRange =
        (filters['price_range'] as Map?)?.cast<String, dynamic>() ?? const {};

    final rawItems = json['data'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map(
                (item) => RentalPlaceItemModel.fromJson(
                  item.cast<String, dynamic>(),
                ),
              )
              .where((item) => item.availableTimeSlots.isNotEmpty)
              .toList()
        : const <RentalPlaceItemModel>[];

    final minPrice = (priceRange['min_price'] as num?)?.toInt() ?? 0;
    final maxPrice = (priceRange['max_price'] as num?)?.toInt() ?? minPrice;

    return RentalPlacesResponseModel(
      items: items,
      minPrice: minPrice,
      maxPrice: maxPrice < minPrice ? minPrice : maxPrice,
    );
  }

  RentalPlacesResult toEntity() {
    return RentalPlacesResult(
      items: items.map((item) => item.toEntity()).toList(),
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }
}

class RentalPlaceItemModel {
  const RentalPlaceItemModel({
    required this.id,
    required this.dateText,
    required this.title,
    required this.room,
    required this.capacity,
    required this.availableTimeSlots,
    required this.price,
    required this.photoUrl,
    required this.isFavorite,
  });

  final int id;
  final String dateText;
  final String title;
  final String room;
  final int capacity;
  final List<String> availableTimeSlots;
  final int price;
  final String? photoUrl;
  final bool isFavorite;

  factory RentalPlaceItemModel.fromJson(Map<String, dynamic> json) {
    final typeName = (json['type_name'] as String?)?.trim();
    final numberPlace = (json['number_place'] as num?)?.toInt() ?? 0;
    final rawPrice = json['price'];
    final parsedPrice = rawPrice is num
        ? rawPrice.toInt()
        : int.tryParse(rawPrice?.toString().split('.').first ?? '') ?? 0;
    final rawSlots = json['available_slots'];
    final slots = rawSlots is List
        ? rawSlots
              .whereType<Map>()
              .map((slot) => (slot['time'] as String?)?.trim() ?? '')
              .where((slot) => slot.isNotEmpty)
              .toList()
        : <String>[];
    final rawPhotoUrl = (json['photo_url'] as String?)?.trim();

    return RentalPlaceItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      dateText: RentalDateTextHelper.formatFullDateFromApi(
        (json['created_at'] as String?)?.trim(),
      ),
      title: 'Аренда ${typeName?.isNotEmpty == true ? typeName : 'помещения'}',
      room: 'Кабинет №$numberPlace',
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      availableTimeSlots: RentalTimeSlotsHelper.mergeContinuousRanges(slots),
      price: parsedPrice,
      photoUrl: _buildPhotoUrl(rawPhotoUrl),
      isFavorite: json['is_favorite'] == true,
    );
  }

  OfficeRentalItem toEntity() {
    return OfficeRentalItem(
      id: id,
      dateText: dateText,
      title: title,
      room: room,
      capacity: capacity,
      availableTimeSlots: availableTimeSlots,
      price: price,
      photoUrl: photoUrl,
      isFavorite: isFavorite,
    );
  }

  static String? _buildPhotoUrl(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return null;
    if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
      return photoUrl;
    }
    return '${AppApiConfig.baseOrigin}$photoUrl';
  }
}
