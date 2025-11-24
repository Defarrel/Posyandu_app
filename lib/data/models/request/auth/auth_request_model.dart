import 'dart:convert';

class LoginRequestModel {
  final String? username;
  final String? password;

  LoginRequestModel({this.username, this.password});

  factory LoginRequestModel.fromJson(String str) =>
      LoginRequestModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LoginRequestModel.fromMap(Map<String, dynamic> json) =>
      LoginRequestModel(username: json["username"], password: json["password"]);

  Map<String, dynamic> toMap() => {"username": username, "password": password};
}

class UpdateUsernameRequestModel {
  final String username;

  UpdateUsernameRequestModel({required this.username});

  Map<String, dynamic> toMap() => {"username": username};

  String toJson() => json.encode(toMap());
}

class UpdatePasswordRequestModel {
  final String oldPassword;
  final String newPassword;

  UpdatePasswordRequestModel({
    required this.oldPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toMap() => {
    "password_lama": oldPassword,
    "password_baru": newPassword,
  };

  String toJson() => json.encode(toMap());
}
