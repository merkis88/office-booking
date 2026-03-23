import 'package:wordpice/core/config/app_api_config.dart';
import 'package:wordpice/features/archive/presentation/models/archive_item.dart';

class ArchivePlacesResponseModel {
  const ArchivePlacesResponseModel({required this.items});

  factory ArchivePlacesResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final items = rawData is List
        ? rawData
              .whereType<Map>()
              .map((item) => _mapItem(item.cast<String, dynamic>()))
              .whereType<ArchiveItem>()
              .toList()
        : const <ArchiveItem>[];

    return ArchivePlacesResponseModel(items: items);
  }

  final List<ArchiveItem> items;

  static ArchiveItem? _mapItem(Map<String, dynamic> item) {
    final id = (item['id'] as num?)?.toInt();
    if (id == null) {
      return null;
    }

    final name = (item['name'] as String?)?.trim() ?? '';
    final typeName = (item['type_name'] as String?)?.trim() ?? '';
    final numberPlace = (item['number_place'] as num?)?.toInt() ?? 0;
    final capacity = (item['capacity'] as num?)?.toInt() ?? 0;
    final price = _parsePrice(item['price']);
    final photoUrl = _buildPhotoUrl((item['photo_url'] as String?)?.trim());
    final description = (item['description'] as String?)?.trim() ?? '';

    return ArchiveItem(
      id: id,
      dateText: '',
      title: typeName.isNotEmpty
          ? typeName
          : (name.isNotEmpty ? name : 'Помещение'),
      room: numberPlace > 0 ? 'Кабинет №$numberPlace' : 'Помещение',
      capacity: capacity,
      price: price,
      photoUrl: photoUrl,
      description: description,
    );
  }

  static int _parsePrice(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString().split('.').first ?? '') ?? 0;
  }

  static String? _buildPhotoUrl(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }
    if (rawValue.startsWith('http://') || rawValue.startsWith('https://')) {
      return rawValue;
    }
    return '${AppApiConfig.baseOrigin}$rawValue';
  }
}
