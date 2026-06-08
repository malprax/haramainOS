enum UserRole { adminTravel, jamaah }

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String password;
  final UserRole role;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      role: UserRole.values.firstWhere(
        (item) => item.name == json['role'],
        orElse: () => UserRole.jamaah,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'password': password,
      'role': role.name,
    };
  }
}
