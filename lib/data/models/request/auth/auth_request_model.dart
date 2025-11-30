import 'dart:convert';

class LoginRequestModel {
  final String? email; 
  final String? password;

  LoginRequestModel({this.email, this.password});

  factory LoginRequestModel.fromJson(String str) =>
      LoginRequestModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LoginRequestModel.fromMap(Map<String, dynamic> json) =>
      LoginRequestModel(email: json["email"], password: json["password"]); 

  Map<String, dynamic> toMap() => {"email": email, "password": password};
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
