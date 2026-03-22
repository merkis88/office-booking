import 'package:wordpice/features/auth/data/models/register_response_model.dart';
import 'package:wordpice/features/auth/domain/entities/registered_user.dart';

class ProfileResponseModel {
  const ProfileResponseModel({required this.user});

  final RegisteredUserModel user;

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileResponseModel(
      user: RegisteredUserModel.fromJson(
        (json['data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
      ),
    );
  }

  RegisteredUser toEntity() {
    return user.toEntity();
  }
}
