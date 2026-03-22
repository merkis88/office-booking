import 'package:wordpice/features/requests/data/datasources/requests_data_source.dart';
import 'package:wordpice/features/requests/domain/entities/create_request_params.dart';
import 'package:wordpice/features/requests/domain/entities/create_request_result.dart';
import 'package:wordpice/features/requests/domain/entities/request_booking_option.dart';
import 'package:wordpice/features/requests/domain/repositories/requests_repository.dart';

class RequestsRepositoryImpl implements RequestsRepository {
  RequestsRepositoryImpl(this._dataSource);

  final RequestsDataSource _dataSource;

  @override
  Future<List<RequestBookingOption>> getMyBookings() {
    return _dataSource.getMyBookings();
  }

  @override
  Future<CreateRequestResult> createRequest(CreateRequestParams params) {
    return _dataSource.createRequest(params);
  }
}
