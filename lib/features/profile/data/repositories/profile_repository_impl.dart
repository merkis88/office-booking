import 'package:wordpice/app/app_session.dart';
import 'package:wordpice/features/auth/domain/entities/registered_user.dart';
import 'package:wordpice/features/profile/data/datasources/profile_data_source.dart';
import 'package:wordpice/features/profile/domain/entities/rental_history_item.dart';
import 'package:wordpice/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._dataSource, {required AppSession appSession})
    : _appSession = appSession;

  final ProfileDataSource _dataSource;
  final AppSession _appSession;

  @override
  Future<RegisteredUser> getCurrentProfile() async {
    final user = await _dataSource.getCurrentProfile();
    _appSession.updateUser(user);
    return user;
  }

  @override
  Future<List<RentalHistoryItem>> getRentalHistory() {
    return _dataSource.getRentalHistory();
  }
}
