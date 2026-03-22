import 'package:wordpice/features/rentals/domain/entities/create_booking_params.dart';
import 'package:wordpice/features/rentals/domain/entities/create_booking_result.dart';
import 'package:wordpice/features/rentals/domain/entities/rental_place_details.dart';
import 'package:wordpice/features/rentals/domain/entities/rental_places_result.dart';

abstract class RentalsRepository {
  Future<RentalPlacesResult> getPlaces({
    required String type,
    String? date,
    required int minPrice,
    required int maxPrice,
  });

  Future<RentalPlaceDetails> getPlaceDetails({
    required int placeId,
    String? date,
  });

  Future<CreateBookingResult> createBooking(CreateBookingParams params);

  Future<void> addFavorite({required int placeId});

  Future<void> removeFavorite({required int placeId});
}
