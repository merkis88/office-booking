import 'package:wordpice/features/auth/domain/entities/registered_user.dart';
import 'package:wordpice/features/profile/data/datasources/profile_data_source.dart';
import 'package:wordpice/features/profile/domain/entities/change_password_params.dart';
import 'package:wordpice/features/profile/domain/entities/profile_rentals_overview.dart';
import 'package:wordpice/features/profile/domain/entities/rental_history_item.dart';
import 'package:wordpice/features/profile/domain/entities/update_profile_params.dart';
import 'package:wordpice/features/profile/presentation/models/profile_request_item.dart';

class ProfileMockDataSource implements ProfileDataSource {
  @override
  Future<RegisteredUser> getCurrentProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const RegisteredUser(
      id: 0,
      firstName: '',
      lastName: '',
      patronymic: null,
      email: '',
      roleName: null,
      post: null,
      company: null,
      photo: null,
      qrHash: null,
      qrVisible: false,
      qrMessage: null,
      qrAvailableFrom: null,
      qrAvailableUntil: null,
      qrTimeWindow: null,
    );
  }

  @override
  Future<List<RentalHistoryItem>> getRentalHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const <RentalHistoryItem>[];
  }

  @override
  Future<ProfileRentalsOverview> getRentalsOverview() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const ProfileRentalsOverview(
      activeRentals: <RentalHistoryItem>[],
      rentalHistory: <RentalHistoryItem>[],
    );
  }

  @override
  Future<List<RentalHistoryItem>> getFavoritePlaces() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const <RentalHistoryItem>[];
  }

  @override
  Future<List<ProfileRequestItem>> getRequests() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const <ProfileRequestItem>[];
  }

  @override
  Future<String> exportRequestPdf(int requestId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return 'mock/request-$requestId.pdf';
  }

  @override
  Future<void> rescheduleBooking({
    required int bookingId,
    required String startTime,
    required String endTime,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  @override
  Future<void> cancelBooking(int bookingId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  @override
  Future<String> changePassword(ChangePasswordParams params) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return 'Пароль успешно обновлен';
  }

  @override
  Future<RegisteredUser> updateProfile(UpdateProfileParams params) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return RegisteredUser(
      id: 0,
      firstName: params.firstName,
      lastName: params.lastName,
      patronymic: params.patronymic.isEmpty ? null : params.patronymic,
      email: params.email,
      roleName: null,
      post: null,
      company: null,
      photo: null,
      qrHash: null,
      qrVisible: false,
      qrMessage: null,
      qrAvailableFrom: null,
      qrAvailableUntil: null,
      qrTimeWindow: null,
    );
  }

  @override
  Future<String?> uploadProfilePhoto(String filePath) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return null;
  }

  @override
  Future<void> deleteAccount(String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
}
