import 'package:wordpice/features/requests/domain/entities/request_service_type.dart';

class RequestServiceTypesResponseModel {
  const RequestServiceTypesResponseModel({required this.items});

  factory RequestServiceTypesResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final items = rawData is List
        ? rawData
              .whereType<Map>()
              .map((item) => _mapItem(item.cast<String, dynamic>()))
              .whereType<RequestServiceType>()
              .toList()
        : const <RequestServiceType>[];

    return RequestServiceTypesResponseModel(items: items);
  }

  final List<RequestServiceType> items;

  static RequestServiceType? _mapItem(Map<String, dynamic> item) {
    final id = (item['id'] as num?)?.toInt();
    final name = item['name']?.toString().trim();
    if (id == null || name == null || name.isEmpty) {
      return null;
    }

    return RequestServiceType(id: id, name: name);
  }
}
