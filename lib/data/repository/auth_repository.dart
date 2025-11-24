import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:posyandu_app/data/models/request/auth/auth_request_model.dart';
import 'package:posyandu_app/data/models/response/auth/auth_response_model.dart';
import 'package:posyandu_app/services/services_http_client.dart';
import 'package:posyandu_app/services/user_notifier.dart';

class AuthRepository {
  final ServiceHttpClient _serviceHttpClient;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthRepository(this._serviceHttpClient);

  Future<Either<String, AuthResponseModel>> login(
    LoginRequestModel requestModel,
  ) async {
    try {
      final http.Response response = await _serviceHttpClient.post(
        "auth/login",
        requestModel.toMap(),
      );

      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        final authResponse = AuthResponseModel.fromMap(jsonResponse);

        await _secureStorage.write(
          key: "authToken",
          value: authResponse.token ?? '',
        );
        await _secureStorage.write(
          key: "userId",
          value: authResponse.username?.id.toString() ?? '',
        );
        await _secureStorage.write(
          key: "userName",
          value: authResponse.username?.username ?? '',
        );

        log("Login success: ${authResponse.username?.username}");
        return Right(authResponse);
      } else {
        final message = jsonResponse['message'] ?? "Login failed";
        log("Login failed: $message");
        return Left(message);
      }
    } catch (e) {
      log("Login exception: $e");
      return Left("An error occurred while logging in.");
    }
  }

  // UPDATE USERNAME
  Future<Either<String, String>> updateUsername(String newName) async {
    try {
      final model = UpdateUsernameRequestModel(username: newName);

      final response = await _serviceHttpClient.put(
        "auth/update-username",
        model.toMap(),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        await getUserProfile();

        return Right(jsonResponse["message"] ?? "Berhasil update username");
      }

      return Left(jsonResponse["message"] ?? "Gagal update username");
    } catch (e) {
      return Left("Terjadi kesalahan");
    }
  }

  // UPDATE PASSWORD
  Future<Either<String, String>> updatePassword(
    String oldPw,
    String newPw,
  ) async {
    try {
      final model = UpdatePasswordRequestModel(
        oldPassword: oldPw,
        newPassword: newPw,
      );

      final response = await _serviceHttpClient.put(
        "auth/update-password",
        model.toMap(),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return Right(jsonResponse["message"] ?? "Berhasil update password");
      }

      return Left(jsonResponse["message"] ?? "Gagal update password");
    } catch (e) {
      return Left("Terjadi kesalahan");
    }
  }

  // UPDATE FOTO PROFILE
  Future<Either<String, Map<String, dynamic>>> updateProfilePhoto(
    File imageFile,
  ) async {
    try {
      final token = await _secureStorage.read(key: "authToken");

      final baseUrlClean = _serviceHttpClient.baseUrl.endsWith('/')
          ? _serviceHttpClient.baseUrl.substring(
              0,
              _serviceHttpClient.baseUrl.length - 1,
            )
          : _serviceHttpClient.baseUrl;

      final request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrlClean/auth/update-photo"),
      );

      request.headers["Authorization"] = "Bearer $token";

      request.files.add(
        await http.MultipartFile.fromPath("foto", imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        await getUserProfile();

        return Right(jsonResponse ?? "Berhasil update foto profile");
      }

      return Left(jsonResponse["message"] ?? "Gagal update foto profile");
    } catch (e) {
      return Left("Terjadi kesalahan");
    }
  }

  // GET ME
  Future<Either<String, User>> getUserProfile() async {
    try {
      final token = await _secureStorage.read(key: "authToken");

      String baseUrl = _serviceHttpClient.baseUrl;
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }
      final url = Uri.parse("$baseUrl/auth/me");

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.body.trim().startsWith("<")) {
        return Left("Server Error (HTML Response). Cek URL/Backend.");
      }

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final user = User.fromMap(jsonResponse);

        log("UPDATING USER NOTIFIER: ${user.username} - ${user.fotoProfile}");
        UserNotifier.update(user);

        if (user.username != null) {
          await _secureStorage.write(key: "username", value: user.username!);
        }

        return Right(user);
      } else {
        return Left(jsonResponse['message'] ?? "Gagal memuat profil");
      }
    } catch (e) {
      log("Get Profile Error: $e");
      return Left("Terjadi kesalahan koneksi");
    }
  }

  // DELETE PHOTO
  Future<Either<String, String>> deleteProfilePhoto() async {
    try {
      final token = await _secureStorage.read(key: "authToken");

      final baseUrlClean = _serviceHttpClient.baseUrl.endsWith('/')
          ? _serviceHttpClient.baseUrl.substring(
              0,
              _serviceHttpClient.baseUrl.length - 1,
            )
          : _serviceHttpClient.baseUrl;

      final response = await http.delete(
        Uri.parse("$baseUrlClean/auth/delete-photo"),
        headers: {"Authorization": "Bearer $token"},
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        await getUserProfile();
        return Right(jsonResponse["message"] ?? "Foto berhasil dihapus");
      }

      return Left(jsonResponse["message"] ?? "Gagal menghapus foto");
    } catch (e) {
      return Left("Terjadi kesalahan koneksi: $e");
    }
  }
}
