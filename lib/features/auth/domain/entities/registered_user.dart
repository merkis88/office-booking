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

  bool get isAdmin => roleName?.trim().toLowerCase() == 'admin';

  RegisteredUser copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? patronymic,
    String? email,
    String? roleName,
    String? post,
    String? company,
    String? photo,
    String? qrHash,
    bool? qrVisible,
    String? qrMessage,
    String? qrAvailableFrom,
    String? qrAvailableUntil,
    String? qrTimeWindow,
  }) {
    return RegisteredUser(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      patronymic: patronymic ?? this.patronymic,
      email: email ?? this.email,
      roleName: roleName ?? this.roleName,
      post: post ?? this.post,
      company: company ?? this.company,
      photo: photo ?? this.photo,
      qrHash: qrHash ?? this.qrHash,
      qrVisible: qrVisible ?? this.qrVisible,
      qrMessage: qrMessage ?? this.qrMessage,
      qrAvailableFrom: qrAvailableFrom ?? this.qrAvailableFrom,
      qrAvailableUntil: qrAvailableUntil ?? this.qrAvailableUntil,
      qrTimeWindow: qrTimeWindow ?? this.qrTimeWindow,
    );
  }
}
