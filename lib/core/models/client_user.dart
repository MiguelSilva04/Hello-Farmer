class ClientUser {
  final String id;
  String firstName;
  String lastName;
  String email;
  String gender;
  String phone;
  String recoveryEmail;
  String dateOfBirth;
  String imageUrl;
  String? backgroundUrl;
  String? nickname;
  String? aboutMe;
  String? status;
  String? iconStatus;
  String? customStatus;
  String? customIconStatus;
  List<String>? friendsIds;
  bool? isProducer;

  ClientUser({
    required this.gender,
    required this.phone,
    required this.recoveryEmail,
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.imageUrl,
    required this.dateOfBirth,
    required this.isProducer,
    this.backgroundUrl,
    this.nickname,
    this.aboutMe,
    this.status,
    this.iconStatus,
    this.customStatus,
    this.customIconStatus,
    this.friendsIds,
  });

  factory ClientUser.fromMap(Map<String, dynamic> map) {
    return ClientUser(
      id: map['id'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      gender: map['gender'] ?? '',
      phone: map['phone'] ?? '',
      recoveryEmail: map['recoverEmail'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      isProducer: map['isProducer'] ?? '',
    );
  }
}
