import 'package:wordpice/features/auth/domain/entities/registered_user.dart';
import 'package:wordpice/features/profile/domain/entities/change_password_params.dart';
import 'package:wordpice/features/profile/domain/entities/profile_rentals_overview.dart';
import 'package:wordpice/features/profile/domain/entities/rental_history_item.dart';

abstract class ProfileRepository {
  Future<RegisteredUser> getCurrentProfile();
  Future<List<RentalHistoryItem>> getRentalHistory();
  Future<ProfileRentalsOverview> getRentalsOverview();
  Future<void> cancelBooking(int bookingId);
  Future<String> changePassword(ChangePasswordParams params);
}
