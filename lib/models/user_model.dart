class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String mobileNumber;
  final String? token;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobileNumber,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      token: json['token'],
    );
  }

  String get fullName => '$firstName $lastName';
}