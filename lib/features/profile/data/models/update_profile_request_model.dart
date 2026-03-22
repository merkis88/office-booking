import 'package:wordpice/features/profile/domain/entities/update_profile_params.dart';

class UpdateProfileRequestModel {
  const UpdateProfileRequestModel({
    required this.firstName,
    required this.lastName,
    required this.patronymic,
    required this.email,
  });

  final String firstName;
  final String lastName;
  final String patronymic;
  final String email;

  factory UpdateProfileRequestModel.fromParams(UpdateProfileParams params) {
    return UpdateProfileRequestModel(
      firstName: params.firstName.trim(),
      lastName: params.lastName.trim(),
      patronymic: params.patronymic.trim(),
      email: params.email.trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'first_name': firstName,
      'last_name': lastName,
      'patronymic': patronymic.isEmpty ? null : patronymic,
      'email': email,
    };
  }
}
