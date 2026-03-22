import 'package:wordpice/core/config/app_api_config.dart';
import 'package:wordpice/features/profile/domain/entities/rental_history_item.dart';

class ProfileFavoritePlacesResponseModel {
  const ProfileFavoritePlacesResponseModel({required this.items});

  factory ProfileFavoritePlacesResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawData = json['data'];
    final items = rawData is List
        ? rawData
              .whereType<Map>()
              .map((item) => _mapItem(item.cast<String, dynamic>()))
              .whereType<RentalHistoryItem>()
              .toList()
        : const <RentalHistoryItem>[];

    return ProfileFavoritePlacesResponseModel(items: items);
  }

  final List<RentalHistoryItem> items;

  static RentalHistoryItem? _mapItem(Map<String, dynamic> item) {
    final id = (item['id'] as num?)?.toInt();
    final type = (item['type'] as String? ?? '').trim();
    final name = (item['name'] as String? ?? '').trim();
    final numberPlace = (item['number_place'] as num?)?.toInt() ?? 0;
    final capacity = (item['capacity'] as num?)?.toInt() ?? 0;
    final price = _parsePrice(item['price']);
    final photo = _buildPhotoUrl((item['photo'] as String?)?.trim());

    if (id == null) {
      return null;
    }

    return RentalHistoryItem(
      placeId: id,
      placeType: type,
      dateLabel: '',
      title: name.isNotEmpty ? name : _mapTypeToTitle(type),
      room: numberPlace > 0 ? 'Кабинет №$numberPlace' : 'Помещение',
      capacity: 'Вместимость: $capacity человек',
      priceLabel: price > 0 ? 'Стоимость: $priceр/час' : '',
      timeSlots: const <String>[],
      photoUrl: photo,
      isFavorite: item['is_favorite'] == true,
    );
  }

  static int _parsePrice(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString().split('.').first ?? '') ?? 0;
  }

  static String _mapTypeToTitle(String type) {
    switch (type) {
      case 'meeting_room':
      case 'meeting':
        return 'Переговорная';
      case 'office':
        return 'Офис';
      case 'coworking':
        return 'Коворкинг';
      default:
        return 'Помещение';
    }
  }

  static String? _buildPhotoUrl(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) return null;
    if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
      return photoPath;
    }
    return '${AppApiConfig.baseOrigin}/storage/$photoPath';
  }
}
