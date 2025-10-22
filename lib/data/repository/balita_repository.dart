import 'dart:convert';
import 'dart:developer';
import 'package:posyandu_app/data/models/request/balita/balita_request_model.dart';
import 'package:posyandu_app/data/models/response/balita/balita_response.dart';
import 'package:posyandu_app/services/services_http_client.dart';
import 'package:dartz/dartz.dart';

class BalitaRepository {
  final ServiceHttpClient _service = ServiceHttpClient();

  Future<Either<String, String>> tambahBalita(
    BalitaRequestModel requestModel,
  ) async {
    try {
      final response = await _service.postWithToken(
        "balita",
        requestModel.toMap(),
      );
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 201) {
        return Right(
          jsonResponse['message'] ?? "Data balita berhasil ditambahkan",
        );
      } else {
        return Left(jsonResponse['message'] ?? "Gagal menambahkan data balita");
      }
    } catch (e) {
      log("Exception tambahBalita: $e");
      return Left("Terjadi kesalahan saat menambahkan balita");
    }
  }

  Future<Either<String, List<BalitaResponseModel>>> getBalita() async {
    try {
      final response = await _service.get("balita");
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonResponse;
        final result = list.map((e) => BalitaResponseModel.fromMap(e)).toList();
        return Right(result);
      } else {
        return Left(jsonResponse['message'] ?? "Gagal mengambil data balita");
      }
    } catch (e) {
      log("Exception getBalita: $e");
      return Left("Terjadi kesalahan saat mengambil data balita");
    }
  }

  Future<Either<String, BalitaResponseModel>> getBalitaByNIK(String nik) async {
    try {
      final response = await _service.get("balita/$nik");
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return Right(BalitaResponseModel.fromMap(jsonResponse));
      } else {
        return Left(jsonResponse['message'] ?? "Data balita tidak ditemukan");
      }
    } catch (e) {
      log("Exception getBalitaByNIK: $e");
      return Left("Terjadi kesalahan saat mengambil data balita");
    }
  }

  Future<Either<String, String>> updateBalita(
    String nik,
    BalitaRequestModel requestModel,
  ) async {
    try {
      final response = await _service.put("balita/$nik", requestModel.toMap());
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return Right(
          jsonResponse['message'] ?? "Data balita berhasil diperbarui",
        );
      } else {
        return Left(jsonResponse['message'] ?? "Gagal memperbarui data balita");
      }
    } catch (e) {
      log("Exception updateBalita: $e");
      return Left("Terjadi kesalahan saat memperbarui balita");
    }
  }

  Future<Either<String, String>> deleteBalita(String nik) async {
    try {
      final response = await _service.delete("balita/$nik");
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return Right(jsonResponse['message'] ?? "Data balita berhasil dihapus");
      } else {
        return Left(jsonResponse['message'] ?? "Gagal menghapus balita");
      }
    } catch (e) {
      log("Exception deleteBalita: $e");
      return Left("Terjadi kesalahan saat menghapus balita");
    }
  }
}
