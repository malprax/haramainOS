enum UserRole { adminTravel, jamaah, mutawwif }

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String password;
  final String? avatar;
  final String? phoneNumber;
  final bool verified;
  final bool emailVisibility;
  final UserRole role;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
    this.avatar,
    this.phoneNumber,
    this.verified = false,
    this.emailVisibility = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      verified: json['verified'] == true,
      emailVisibility: json['emailVisibility'] == true,
      role: parseRole(json['role']),
    );
  }

  static UserRole parseRole(dynamic value) {
    final roleText = value?.toString().trim();

    if (roleText == 'adminTravel') {
      return UserRole.adminTravel;
    }

    if (roleText == 'mutawwif') {
      return UserRole.mutawwif;
    }

    return UserRole.jamaah;
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'role': role.name,
      'avatar': avatar,
      'phoneNumber': phoneNumber,
      'verified': verified,
      'emailVisibility': emailVisibility,
    };
  }
}
