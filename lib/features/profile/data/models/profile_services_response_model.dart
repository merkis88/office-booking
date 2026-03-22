import 'package:wordpice/features/profile/presentation/models/profile_request_item.dart';

class ProfileServicesResponseModel {
  ProfileServicesResponseModel({required this.items});

  factory ProfileServicesResponseModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['data'];
    if (rawItems is! List) {
      return ProfileServicesResponseModel(items: const <ProfileRequestItem>[]);
    }

    return ProfileServicesResponseModel(
      items: rawItems
          .whereType<Map>()
          .map(
            (item) => _ProfileServiceItemModel.fromJson(
              Map<String, dynamic>.from(item),
            ).toEntity(),
          )
          .toList(),
    );
  }

  final List<ProfileRequestItem> items;
}

class _ProfileServiceItemModel {
  _ProfileServiceItemModel({
    required this.id,
    required this.serviceTypeId,
    required this.serviceTypeName,
    required this.placeType,
    required this.placeNumber,
    required this.bookingStartTime,
    required this.bookingEndTime,
    required this.comment,
  });

  factory _ProfileServiceItemModel.fromJson(Map<String, dynamic> json) {
    final booking = _asMap(json['booking']);
    final place = _asMap(json['place']).isNotEmpty
        ? _asMap(json['place'])
        : _asMap(booking['place']);
    final serviceType = _asMap(json['service_type']);

    return _ProfileServiceItemModel(
      id: _asInt(json['id']),
      serviceTypeId: _asInt(json['service_type_id']),
      serviceTypeName: serviceType['name']?.toString(),
      placeType: place['type']?.toString(),
      placeNumber:
          place['number_place']?.toString() ??
          place['place_number']?.toString() ??
          booking['place_number']?.toString() ??
          booking['place_id']?.toString() ??
          json['booking_id']?.toString() ??
          '-',
      bookingStartTime: booking['start_time']?.toString(),
      bookingEndTime: booking['end_time']?.toString(),
      comment: json['comment']?.toString(),
    );
  }

  final int id;
  final int serviceTypeId;
  final String? serviceTypeName;
  final String? placeType;
  final String placeNumber;
  final String? bookingStartTime;
  final String? bookingEndTime;
  final String? comment;

  ProfileRequestItem toEntity() {
    return ProfileRequestItem(
      id: id,
      number: id,
      requestType: _resolveRequestType(),
      roomType: _resolveRoomType(),
      roomNumber: placeNumber,
      workTime: _resolveWorkTime(),
      comment: (comment == null || comment!.trim().isEmpty)
          ? 'Нет комментария'
          : comment!.trim(),
      hasAttachment: true,
      attachmentLabel: 'pdf',
    );
  }

  String _resolveRequestType() {
    switch (serviceTypeId) {
      case 1:
        return 'Клининг';
      case 2:
        return 'ТО';
      default:
        final name = serviceTypeName?.trim();
        return (name == null || name.isEmpty) ? 'Заявка' : name;
    }
  }

  String _resolveRoomType() {
    switch (placeType) {
      case 'meeting_room':
        return 'Переговорная';
      case 'office':
        return 'Офис';
      case 'coworking':
        return 'Коворкинг';
      default:
        return 'Помещение';
    }
  }

  String _resolveWorkTime() {
    final start = _extractTime(bookingStartTime);
    final end = _extractTime(bookingEndTime);
    if (start != null && end != null) {
      return '$start - $end';
    }
    if (start != null) {
      return start;
    }
    return '-';
  }

  String? _extractTime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final match = RegExp(r'(\d{2}:\d{2})').firstMatch(value);
    return match?.group(1);
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const <String, dynamic>{};
  }

  static int _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
