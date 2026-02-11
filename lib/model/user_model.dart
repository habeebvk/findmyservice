class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String role;
  final String? workType;
  final String? profilePic;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.workType,
    this.profilePic,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'workType': workType,
      'profilePic': profilePic,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
      workType: map['workType'],
      profilePic: map['profilePic'],
    );
  }
}
