import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:posyandu_app/core/components/custom_snackbar.dart';
import 'package:posyandu_app/main.dart';
import 'package:posyandu_app/presentation/auth/login_screen.dart';

class ServiceHttpClient {
  final String baseUrl = 'http://10.222.155.125:5000/api/';
  final secureStorage = FlutterSecureStorage();
  static bool _isLoggingOut = false;

  // POST tanpa token
  Future<http.Response> post(String endPoint, Map<String, dynamic> body) async {
    final url = Uri.parse("$baseUrl$endPoint");

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      return await _checkResponse(response);
    } catch (e) {
      throw Exception("POST request failed: $e");
    }
  }

  // POST dengan token
  Future<http.Response> postWithToken(
    String endPoint,
    Map<String, dynamic> body,
  ) async {
    final token = await secureStorage.read(key: "authToken");
    final url = Uri.parse("$baseUrl$endPoint");

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      return await _checkResponse(response);
    } catch (e) {
      throw Exception("POST with token failed: $e");
    }
  }

  // GET
  Future<http.Response> get(String endPoint) async {
    final token = await secureStorage.read(key: "authToken");
    final url = Uri.parse("$baseUrl$endPoint");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      return await _checkResponse(response);
    } catch (e) {
      throw Exception("GET request failed: $e");
    }
  }

  // PUT
  Future<http.Response> put(String endPoint, Map<String, dynamic> body) async {
    final token = await secureStorage.read(key: "authToken");
    final url = Uri.parse("$baseUrl$endPoint");

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      return await _checkResponse(response);
    } catch (e) {
      throw Exception("PUT request failed: $e");
    }
  }

  // DELETE
  Future<http.Response> delete(String endPoint) async {
    final token = await secureStorage.read(key: "authToken");
    final url = Uri.parse("$baseUrl$endPoint");

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      return await _checkResponse(response);
    } catch (e) {
      throw Exception("DELETE request failed: $e");
    }
  }

  // HANDLE TOKEN EXPIRED
  Future<void> _handleTokenExpired() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    await secureStorage.delete(key: "authToken");

    if (navigatorKey.currentContext != null) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        CustomSnackBar.show(
          message: "Sesi anda telah habis, silahkan login kembali",
          type: SnackBarType.error,
        ),
      );
    }

    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );

    Future.delayed(const Duration(seconds: 2), () {
      _isLoggingOut = false;
    });
  }

  // UNIVERSAL RESPONSE CHECKER
  Future<http.Response> _checkResponse(http.Response response) async {
    if (response.statusCode == 401) {
      try {
        final jsonRes = jsonDecode(response.body);
        if (jsonRes is Map && jsonRes["message"] == "Token expired") {
          await _handleTokenExpired();
        }
      } catch (_) {}

      await _handleTokenExpired();
    }

    return response;
  }

  // HANDLE TOKEN EXPIRED
  Future<void> handleTokenExpiredFromOutside() async {
    await secureStorage.delete(key: "authToken");
  }
}
