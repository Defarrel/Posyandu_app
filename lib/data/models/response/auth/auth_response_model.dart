import 'dart:convert';

class AuthResponseModel {
  final String? token;
  final User? user; 

  AuthResponseModel({this.token, this.user});

  factory AuthResponseModel.fromJson(String str) =>
      AuthResponseModel.fromMap(json.decode(str));

  factory AuthResponseModel.fromMap(Map<String, dynamic> json) =>
      AuthResponseModel(
        token: json["token"],
        user: json["user"] == null
            ? null
            : User.fromMap(json["user"]),
      );

  Map<String, dynamic> toMap() => {
    "token": token,
    "user": user?.toMap(), 
  };
}

class User {
  final int? id;
  final String? username;
  final String? email; 
  final String? role;
  final String? fotoProfile;

  User({this.id, this.username, this.email, this.role, this.fotoProfile});

  factory User.fromMap(Map<String, dynamic> json) => User(
    id: json["id"],
    username: json["username"],
    email: json["email"],
    role: json["role"],
    fotoProfile: json["foto_profile"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "username": username,
    "email": email,
    "role": role,
    "foto_profile": fotoProfile,
  };

  User copyWith({
    int? id,
    String? username,
    String? email, 
    String? role,
    String? fotoProfile,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email, 
      role: role ?? this.role,
      fotoProfile: fotoProfile ?? this.fotoProfile,
    );
  }
}
