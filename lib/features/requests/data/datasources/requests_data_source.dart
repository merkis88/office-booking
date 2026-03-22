import 'package:wordpice/features/requests/domain/entities/create_request_params.dart';
import 'package:wordpice/features/requests/domain/entities/create_request_result.dart';
import 'package:wordpice/features/requests/domain/entities/request_booking_option.dart';

abstract class RequestsDataSource {
  Future<List<RequestBookingOption>> getMyBookings();
  Future<CreateRequestResult> createRequest(CreateRequestParams params);
}
