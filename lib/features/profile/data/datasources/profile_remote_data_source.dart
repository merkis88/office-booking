import 'package:wordpice/app/app_session.dart';
import 'package:wordpice/core/network/api_client.dart';
import 'package:wordpice/features/auth/domain/entities/registered_user.dart';
import 'package:wordpice/features/profile/data/datasources/profile_data_source.dart';
import 'package:wordpice/features/profile/data/models/profile_response_model.dart';
import 'package:wordpice/features/profile/domain/entities/rental_history_item.dart';

class ProfileRemoteDataSource implements ProfileDataSource {
  ProfileRemoteDataSource(this._apiClient, this._appSession);

  final ApiClient _apiClient;
  final AppSession _appSession;

  @override
  Future<RegisteredUser> getCurrentProfile() async {
    final token = _appSession.token;
    final response = await _apiClient.getJson(
      '/me',
      headers: token == null || token.isEmpty
          ? null
          : <String, String>{'Authorization': 'Bearer $token'},
    );
    final statusCode = response['statusCode'] as int? ?? 500;

    if (statusCode >= 200 && statusCode < 300 && response['success'] == true) {
      return ProfileResponseModel.fromJson(response).toEntity();
    }

    throw const ApiConnectionException('Не удалось получить данные профиля.');
  }

  @override
  Future<List<RentalHistoryItem>> getRentalHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const <RentalHistoryItem>[];
  }
}
