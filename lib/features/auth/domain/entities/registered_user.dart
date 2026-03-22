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
    required this.qrHash,
    required this.qrVisible,
    required this.qrMessage,
    required this.qrAvailableFrom,
    required this.qrAvailableUntil,
    required this.qrTimeWindow,
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
  final String? qrHash;
  final bool qrVisible;
  final String? qrMessage;
  final String? qrAvailableFrom;
  final String? qrAvailableUntil;
  final String? qrTimeWindow;

  String get fullName {
    return <String>[
      lastName.trim(),
      firstName.trim(),
      patronymic?.trim() ?? '',
    ].where((part) => part.isNotEmpty).join(' ');
  }

  bool get hasQrCode {
    return qrVisible ||
        (qrHash?.trim().isNotEmpty ?? false) ||
        (qrAvailableFrom?.trim().isNotEmpty ?? false) ||
        (qrAvailableUntil?.trim().isNotEmpty ?? false) ||
        (qrTimeWindow?.trim().isNotEmpty ?? false);
  }
}
