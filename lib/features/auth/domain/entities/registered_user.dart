class RegisteredUser {
  const RegisteredUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.patronymic,
    required this.email,
    required this.roleName,
    required this.post,
    required this.company,
    required this.photo,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String? patronymic;
  final String email;
  final String? roleName;
  final String? post;
  final String? company;
  final String? photo;

  String get fullName {
    return <String>[
      lastName.trim(),
      firstName.trim(),
      patronymic?.trim() ?? '',
    ].where((part) => part.isNotEmpty).join(' ');
  }
}
