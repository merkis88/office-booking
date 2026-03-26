import 'package:wordpice/features/rentals/data/models/create_booking_request_model.dart';
import 'package:wordpice/features/rentals/data/models/create_booking_response_model.dart';
import 'package:wordpice/features/rentals/data/models/rental_place_details_response_model.dart';
import 'package:wordpice/features/rentals/data/models/rental_places_response_model.dart';

abstract class RentalsDataSource {
  Future<RentalPlacesResponseModel> getPlaces({
    required String type,
    String? date,
    required int minPrice,
    required int maxPrice,
  });

  Future<RentalPlaceDetailsResponseModel> getPlaceDetails({
    required int placeId,
    String? date,
  });

  Future<CreateBookingResponseModel> createBooking(
    CreateBookingRequestModel request,
  );

  Future<void> addFavorite({required int placeId});

  Future<void> removeFavorite({required int placeId});

  Future<void> archivePlace({required int placeId});
}
