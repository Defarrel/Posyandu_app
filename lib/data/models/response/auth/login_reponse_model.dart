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

  User({this.id, this.username, this.role});

  factory User.fromMap(Map<String, dynamic> json) =>
      User(id: json["id"], username: json["username"], role: json["role"]);

  Map<String, dynamic> toMap() => {
    "id": id,
    "username": username,
    "role": role,
  };
}
