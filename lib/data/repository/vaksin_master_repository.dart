import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:posyandu_app/data/models/request/vaksin/vaksin_master_request_model.dart';
import 'package:posyandu_app/data/models/response/vaksin/vaksin_master_response_model.dart';
import 'package:posyandu_app/services/services_http_client.dart';

class VaksinMasterRepository {
  final ServiceHttpClient _service = ServiceHttpClient();

  // GET semua master vaksin
  Future<Either<String, List<VaksinMasterResponseModel>>> getAllVaksin() async {
    try {
      final response = await _service.get("vaksin/master");
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List data = jsonResponse["data"];
        return Right(
          data.map((e) => VaksinMasterResponseModel.fromJson(e)).toList(),
        );
      } else {
        return Left(jsonResponse["message"] ?? "Gagal memuat master vaksin");
      }
    } catch (e) {
      return Left("Kesalahan: $e");
    }
  }

  // GET detail vaksin
  Future<Either<String, VaksinMasterResponseModel>> getVaksinById(
    int id,
  ) async {
    try {
      final response = await _service.get("vaksin/master/$id");
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return Right(VaksinMasterResponseModel.fromJson(jsonResponse["data"]));
      } else {
        return Left(jsonResponse["message"] ?? "Data vaksin tidak ditemukan");
      }
    } catch (e) {
      return Left("Kesalahan: $e");
    }
  }

  // POST Tambah vaksin
  Future<Either<String, String>> createVaksin(
    VaksinMasterRequestModel request,
  ) async {
    try {
      final response = await _service.postWithToken(
        "vaksin/master",
        request.toJson(),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(jsonResponse["message"]);
      } else {
        return Left(jsonResponse["message"] ?? "Gagal menambah vaksin");
      }
    } catch (e) {
      return Left("Kesalahan: $e");
    }
  }

  // PUT update vaksin
  Future<Either<String, String>> updateVaksin(
    int id,
    VaksinMasterRequestModel request,
  ) async {
    try {
      final response = await _service.put(
        "vaksin/master/$id",
        request.toJson(),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return Right(jsonResponse["message"]);
      } else {
        return Left(jsonResponse["message"] ?? "Gagal memperbarui vaksin");
      }
    } catch (e) {
      return Left("Kesalahan: $e");
    }
  }

  // DELETE vaksin
  Future<Either<String, String>> deleteVaksin(int id) async {
    try {
      final response = await _service.delete("vaksin/master/$id");
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return Right(jsonResponse["message"]);
      } else {
        return Left(jsonResponse["message"] ?? "Gagal menghapus vaksin");
      }
    } catch (e) {
      return Left("Kesalahan: $e");
    }
  }
}
