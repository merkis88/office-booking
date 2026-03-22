import 'package:wordpice/app/app_session.dart';
import 'package:wordpice/app/app_session_storage.dart';
import 'package:wordpice/features/auth/domain/entities/registered_user.dart';
import 'package:wordpice/features/profile/data/datasources/profile_data_source.dart';
import 'package:wordpice/features/profile/domain/entities/change_password_params.dart';
import 'package:wordpice/features/profile/domain/entities/profile_rentals_overview.dart';
import 'package:wordpice/features/profile/domain/entities/rental_history_item.dart';
import 'package:wordpice/features/profile/domain/entities/update_profile_params.dart';
import 'package:wordpice/features/profile/domain/repositories/profile_repository.dart';
import 'package:wordpice/features/profile/presentation/models/profile_request_item.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(
    this._dataSource, {
    required AppSession appSession,
    required AppSessionStorage sessionStorage,
  }) : _appSession = appSession,
       _sessionStorage = sessionStorage;

  final ProfileDataSource _dataSource;
  final AppSession _appSession;
  final AppSessionStorage _sessionStorage;

  @override
  Future<RegisteredUser> getCurrentProfile() async {
    final user = await _dataSource.getCurrentProfile();
    _appSession.updateUser(user);
    final token = _appSession.token;
    if (token != null && token.isNotEmpty) {
      await _sessionStorage.saveSession(token: token, user: user);
    }
    return user;
  }

  @override
  Future<List<RentalHistoryItem>> getRentalHistory() {
    return _dataSource.getRentalHistory();
  }

  @override
  Future<ProfileRentalsOverview> getRentalsOverview() {
    return _dataSource.getRentalsOverview();
  }

  @override
  Future<List<ProfileRequestItem>> getRequests() {
    return _dataSource.getRequests();
  }

  @override
  Future<String> exportRequestPdf(int requestId) {
    return _dataSource.exportRequestPdf(requestId);
  }

  @override
  Future<void> rescheduleBooking({
    required int bookingId,
    required String startTime,
    required String endTime,
  }) {
    return _dataSource.rescheduleBooking(
      bookingId: bookingId,
      startTime: startTime,
      endTime: endTime,
    );
  }

  @override
  Future<void> cancelBooking(int bookingId) {
    return _dataSource.cancelBooking(bookingId);
  }

  @override
  Future<String> changePassword(ChangePasswordParams params) {
    return _dataSource.changePassword(params);
  }

  @override
  Future<RegisteredUser> updateProfile(UpdateProfileParams params) async {
    final user = await _dataSource.updateProfile(params);
    _appSession.updateUser(user);
    final token = _appSession.token;
    if (token != null && token.isNotEmpty) {
      await _sessionStorage.saveSession(token: token, user: user);
    }
    return user;
  }

  @override
  Future<void> deleteAccount(String password) {
    return _dataSource.deleteAccount(password);
  }
}
