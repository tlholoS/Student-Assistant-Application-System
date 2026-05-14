class UserModel {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String role; // 'student' or 'admin'

  UserModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      role: json['role'] as String? ?? 'student',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
    };
  }
}