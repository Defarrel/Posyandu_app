import 'dart:convert';

class AuthResponseModel {
  final String? token;
  final User? username;

  AuthResponseModel({this.token, this.username});

  factory AuthResponseModel.fromJson(String str) =>
      AuthResponseModel.fromMap(json.decode(str));

  factory AuthResponseModel.fromMap(Map<String, dynamic> json) =>
      AuthResponseModel(
        token: json["token"],
        username: json["username"] == null
            ? null
            : User.fromMap(json["username"]),
      );

  Map<String, dynamic> toMap() => {
    "token": token,
    "username": username?.toMap(),
  };
}

class User {
  final int? id;
  final String? username;
  final String? role;
  final String? fotoProfile;

  User({this.id, this.username, this.role, this.fotoProfile});

  factory User.fromMap(Map<String, dynamic> json) => User(
    id: json["id"],
    username: json["username"],
    role: json["role"],
    fotoProfile: json["foto_profile"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "username": username,
    "role": role,
    "foto_profile": fotoProfile,
  };

  User copyWith({
    int? id,
    String? username,
    String? role,
    String? fotoProfile,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      role: role ?? this.role,
      fotoProfile: fotoProfile ?? this.fotoProfile,
    );
  }
}
