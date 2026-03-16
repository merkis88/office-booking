import 'package:wordpice/features/auth/domain/entities/registered_user.dart';
import 'package:wordpice/features/profile/data/datasources/profile_data_source.dart';
import 'package:wordpice/features/profile/domain/entities/change_password_params.dart';
import 'package:wordpice/features/profile/domain/entities/profile_rentals_overview.dart';
import 'package:wordpice/features/profile/domain/entities/rental_history_item.dart';

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
  Future<void> cancelBooking(int bookingId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  @override
  Future<String> changePassword(ChangePasswordParams params) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return 'Пароль успешно обновлен';
  }
}
