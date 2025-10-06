import 'dart:convert';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:posyandu_app/data/models/request/auth/login_request_model.dart';
import 'package:posyandu_app/data/models/response/auth/login_reponse_model.dart';
import 'package:posyandu_app/services/services_http_client.dart';

class AuthRepository {
  final ServiceHttpClient _serviceHttpClient;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthRepository(this._serviceHttpClient);

  // Login
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
}
