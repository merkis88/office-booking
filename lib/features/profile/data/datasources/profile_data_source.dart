import 'package:wordpice/features/auth/domain/entities/registered_user.dart';
import 'package:wordpice/features/profile/domain/entities/rental_history_item.dart';

abstract class ProfileDataSource {
  Future<RegisteredUser> getCurrentProfile();
  Future<List<RentalHistoryItem>> getRentalHistory();
}
