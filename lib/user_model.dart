class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // e.g., player, coach, admin
  final String? phoneNumber;
  final String? profileImageUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.profileImageUrl,
  });

  static const UserModel empty = UserModel(
    id: '',
    name: '',
    email: '',
    role: '',
    phoneNumber: null,
    profileImageUrl: null,
  );

  static UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
    };
  }
}
