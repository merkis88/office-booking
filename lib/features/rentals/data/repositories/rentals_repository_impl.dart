import 'package:wordpice/features/rentals/data/models/create_booking_request_model.dart';
import 'package:wordpice/features/rentals/data/datasources/rentals_data_source.dart';
import 'package:wordpice/features/rentals/domain/entities/create_booking_params.dart';
import 'package:wordpice/features/rentals/domain/entities/create_booking_result.dart';
import 'package:wordpice/features/rentals/domain/entities/rental_place_details.dart';
import 'package:wordpice/features/rentals/domain/entities/rental_places_result.dart';
import 'package:wordpice/features/rentals/domain/repositories/rentals_repository.dart';

class RentalsRepositoryImpl implements RentalsRepository {
  const RentalsRepositoryImpl(this._dataSource);

  final RentalsDataSource _dataSource;

  @override
  Future<RentalPlacesResult> getPlaces({
    required String type,
    String? date,
    required int minPrice,
    required int maxPrice,
  }) async {
    final response = await _dataSource.getPlaces(
      type: type,
      date: date,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
    return response.toEntity();
  }

  @override
  Future<RentalPlaceDetails> getPlaceDetails({
    required int placeId,
    String? date,
  }) async {
    final response = await _dataSource.getPlaceDetails(
      placeId: placeId,
      date: date,
    );
    return response.toEntity();
  }

  @override
  Future<CreateBookingResult> createBooking(CreateBookingParams params) async {
    final response = await _dataSource.createBooking(
      CreateBookingRequestModel.fromParams(params),
    );
    return response.toEntity();
  }

  @override
  Future<void> addFavorite({required int placeId}) {
    return _dataSource.addFavorite(placeId: placeId);
  }

  @override
  Future<void> removeFavorite({required int placeId}) {
    return _dataSource.removeFavorite(placeId: placeId);
  }

  @override
  Future<void> archivePlace({required int placeId}) {
    return _dataSource.archivePlace(placeId: placeId);
  }

  @override
  Future<void> createGuestQr({
    required int bookingId,
    required String recipientEmail,
  }) {
    return _dataSource.createGuestQr(
      bookingId: bookingId,
      recipientEmail: recipientEmail,
    );
  }

  @override
  Future<void> createUserQr({
    required int bookingId,
    required String email,
  }) {
    return _dataSource.createUserQr(
      bookingId: bookingId,
      email: email,
    );
  }
}
