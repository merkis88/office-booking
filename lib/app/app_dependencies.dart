import 'package:wordpice/app/app_session.dart';
import 'package:wordpice/core/network/api_client.dart';
import 'package:wordpice/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:wordpice/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:wordpice/features/auth/domain/repositories/auth_repository.dart';
import 'package:wordpice/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:wordpice/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:wordpice/features/profile/domain/repositories/profile_repository.dart';
import 'package:wordpice/features/reviews/data/datasources/reviews_remote_data_source.dart';
import 'package:wordpice/features/reviews/data/repositories/reviews_repository_impl.dart';
import 'package:wordpice/features/reviews/domain/repositories/reviews_repository.dart';

class AppDependencies {
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;
  final ReviewsRepository reviewsRepository;
  final AppSession appSession;

  AppDependencies({
    required this.authRepository,
    required this.profileRepository,
    required this.reviewsRepository,
    required this.appSession,
  });

  factory AppDependencies.create() {
    final apiClient = ApiClient();
    final appSession = AppSession();
    final authDataSource = AuthRemoteDataSource(apiClient, appSession);
    final authRepository = AuthRepositoryImpl(
      authDataSource,
      appSession: appSession,
    );

    final profileDataSource = ProfileRemoteDataSource(apiClient, appSession);
    final profileRepository = ProfileRepositoryImpl(
      profileDataSource,
      appSession: appSession,
    );

    final reviewsDataSource = ReviewsRemoteDataSource(apiClient, appSession);
    final reviewsRepository = ReviewsRepositoryImpl(reviewsDataSource);

    return AppDependencies(
      authRepository: authRepository,
      profileRepository: profileRepository,
      reviewsRepository: reviewsRepository,
      appSession: appSession,
    );
  }
}
