import 'package:wordpice/features/requests/domain/entities/create_request_params.dart';

class CreateRequestRequestModel {
  const CreateRequestRequestModel({
    required this.bookingId,
    required this.serviceTypeId,
    required this.serviceDate,
    required this.serviceTime,
    this.comment,
  });

  final int bookingId;
  final int serviceTypeId;
  final String serviceDate;
  final String serviceTime;
  final String? comment;

  factory CreateRequestRequestModel.fromParams(CreateRequestParams params) {
    return CreateRequestRequestModel(
      bookingId: params.bookingId,
      serviceTypeId: params.serviceTypeId,
      serviceDate: params.serviceDate,
      serviceTime: params.serviceTime,
      comment: params.comment?.trim().isNotEmpty == true
          ? params.comment!.trim()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'booking_id': bookingId,
      'service_type_id': serviceTypeId,
      'service_date': serviceDate,
      'service_time': serviceTime,
      if (comment != null) 'comment': comment,
    };
  }
}
