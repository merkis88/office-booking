import 'package:wordpice/features/auth/domain/entities/registered_user.dart';
import 'package:wordpice/features/profile/domain/entities/change_password_params.dart';
import 'package:wordpice/features/profile/domain/entities/profile_rentals_overview.dart';
import 'package:wordpice/features/profile/domain/entities/rental_history_item.dart';
import 'package:wordpice/features/profile/domain/entities/update_profile_params.dart';
import 'package:wordpice/features/profile/presentation/models/profile_request_item.dart';

abstract class ProfileRepository {
  Future<RegisteredUser> getCurrentProfile();
  Future<List<RentalHistoryItem>> getRentalHistory();
  Future<ProfileRentalsOverview> getRentalsOverview();
  Future<List<RentalHistoryItem>> getFavoritePlaces();
  Future<List<ProfileRequestItem>> getRequests();
  Future<String> exportRequestPdf(int requestId);
  Future<void> rescheduleBooking({
    required int bookingId,
    required String startTime,
    required String endTime,
  });
  Future<void> cancelBooking(int bookingId);
  Future<String> changePassword(ChangePasswordParams params);
  Future<RegisteredUser> updateProfile(UpdateProfileParams params);
  Future<void> deleteAccount(String password);
}
