import 'package:wordpice/app/app_session.dart';
import 'package:wordpice/app/app_session_storage.dart';
import 'package:wordpice/core/network/api_client.dart';
import 'package:wordpice/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:wordpice/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:wordpice/features/auth/domain/repositories/auth_repository.dart';
import 'package:wordpice/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:wordpice/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:wordpice/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:wordpice/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:wordpice/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:wordpice/features/profile/domain/repositories/profile_repository.dart';
import 'package:wordpice/features/requests/data/datasources/requests_remote_data_source.dart';
import 'package:wordpice/features/requests/data/repositories/requests_repository_impl.dart';
import 'package:wordpice/features/requests/domain/repositories/requests_repository.dart';
import 'package:wordpice/features/rentals/data/datasources/rentals_remote_data_source.dart';
import 'package:wordpice/features/rentals/data/repositories/rentals_repository_impl.dart';
import 'package:wordpice/features/rentals/domain/repositories/rentals_repository.dart';
import 'package:wordpice/features/reviews/data/datasources/reviews_remote_data_source.dart';
import 'package:wordpice/features/reviews/data/repositories/reviews_repository_impl.dart';
import 'package:wordpice/features/reviews/domain/repositories/reviews_repository.dart';

class AppDependencies {
  final AuthRepository authRepository;
  final NotificationsRepository notificationsRepository;
  final ProfileRepository profileRepository;
  final RequestsRepository requestsRepository;
  final RentalsRepository rentalsRepository;
  final ReviewsRepository reviewsRepository;
  final AppSession appSession;

  AppDependencies({
    required this.authRepository,
    required this.notificationsRepository,
    required this.profileRepository,
    required this.requestsRepository,
    required this.rentalsRepository,
    required this.reviewsRepository,
    required this.appSession,
  });

  static Future<AppDependencies> create() async {
    final apiClient = ApiClient();
    final appSession = AppSession();
    final sessionStorage = AppSessionStorage();
    final storedSession = await sessionStorage.readSession();

    if (storedSession != null) {
      appSession.restore(token: storedSession.token, user: storedSession.user);
    }

    final authDataSource = AuthRemoteDataSource(apiClient, appSession);
    final authRepository = AuthRepositoryImpl(
      authDataSource,
      appSession: appSession,
      sessionStorage: sessionStorage,
    );

    final notificationsDataSource = NotificationsRemoteDataSource(
      apiClient,
      appSession,
    );
    final notificationsRepository = NotificationsRepositoryImpl(
      notificationsDataSource,
    );

    final profileDataSource = ProfileRemoteDataSource(apiClient, appSession);
    final profileRepository = ProfileRepositoryImpl(
      profileDataSource,
      appSession: appSession,
      sessionStorage: sessionStorage,
    );

    final requestsDataSource = RequestsRemoteDataSource(apiClient, appSession);
    final requestsRepository = RequestsRepositoryImpl(requestsDataSource);

    final rentalsDataSource = RentalsRemoteDataSource(apiClient, appSession);
    final rentalsRepository = RentalsRepositoryImpl(rentalsDataSource);

    final reviewsDataSource = ReviewsRemoteDataSource(apiClient, appSession);
    final reviewsRepository = ReviewsRepositoryImpl(reviewsDataSource);

    return AppDependencies(
      authRepository: authRepository,
      notificationsRepository: notificationsRepository,
      profileRepository: profileRepository,
      requestsRepository: requestsRepository,
      rentalsRepository: rentalsRepository,
      reviewsRepository: reviewsRepository,
      appSession: appSession,
    );
  }
}
