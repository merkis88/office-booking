class UpdateProfileParams {
  const UpdateProfileParams({
    required this.firstName,
    required this.lastName,
    required this.patronymic,
    required this.email,
  });

  final String firstName;
  final String lastName;
  final String patronymic;
  final String email;
}
