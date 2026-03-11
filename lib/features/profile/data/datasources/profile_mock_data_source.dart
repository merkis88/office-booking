import 'package:wordpice/features/auth/domain/entities/registered_user.dart';
import 'package:wordpice/features/profile/data/datasources/profile_data_source.dart';
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
}
