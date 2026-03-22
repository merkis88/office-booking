import 'package:wordpice/features/requests/domain/entities/create_request_result.dart';

class CreateRequestResponseModel {
  const CreateRequestResponseModel({
    required this.id,
    required this.message,
  });

  final int id;
  final String message;

  factory CreateRequestResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final id = data is Map ? _parseInt(data['id']) ?? 0 : 0;

    return CreateRequestResponseModel(
      id: id,
      message: json['message']?.toString().trim().isNotEmpty == true
          ? json['message'].toString().trim()
          : 'Заявка успешно создана',
    );
  }

  CreateRequestResult toEntity() {
    return CreateRequestResult(id: id, message: message);
  }

  static int? _parseInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
