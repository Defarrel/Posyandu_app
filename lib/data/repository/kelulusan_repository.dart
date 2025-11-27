import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:posyandu_app/data/models/request/kelulusan/kelulusan_request_model.dart';
import 'package:posyandu_app/data/models/response/kelulusan/kelulusan_response_model.dart';
import 'package:posyandu_app/services/services_http_client.dart';

class KelulusanRepository {
  final ServiceHttpClient _service = ServiceHttpClient();

  // GET detail kelulusan balita
  Future<Either<String, KelulusanDetailResponse>> getDetailKelulusan(
    String nik,
  ) async {
    try {
      final response = await _service.get("kelulusan/$nik");
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse["success"] == true) {
        return Right(KelulusanDetailResponse.fromJson(jsonResponse));
      } else {
        return Left(jsonResponse["message"] ?? "Gagal memuat data kelulusan");
      }
    } catch (e) {
      return Left("Kesalahan: $e");
    }
  }

  // GET semua balita + status kelulusan
  Future<Either<String, KelulusanListResponse>> getSemuaStatus() async {
    try {
      final response = await _service.get("kelulusan/all-status");
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse["success"] == true) {
        return Right(KelulusanListResponse.fromJson(jsonResponse));
      } else {
        return Left(jsonResponse["message"] ?? "Gagal memuat data kelulusan");
      }
    } catch (e) {
      return Left("Kesalahan: $e");
    }
  }

  // SET status kelulusan manual (LULUS/PINDAH)
  Future<Either<String, String>> setKelulusan(
    String nik,
    KelulusanRequestModel model,
  ) async {
    try {
      final response = await _service.postWithToken(
        "kelulusan/$nik/set-lulus",
        model.toJson(),
      );
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse["success"] == true) {
        return Right(jsonResponse["message"]);
      } else {
        return Left(
          jsonResponse["message"] ?? "Gagal menyimpan status kelulusan",
        );
      }
    } catch (e) {
      return Left("Kesalahan: $e");
    }
  }

  // SET pindah manual (alternatif)
  Future<Either<String, String>> setPindahManual(
    String nik, {
    String? keterangan,
  }) async {
    try {
      final response = await _service.postWithToken("kelulusan/$nik/pindah", {
        'keterangan': keterangan ?? "Pindah manual oleh kader",
      });
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse["success"] == true) {
        return Right(jsonResponse["message"]);
      } else {
        return Left(jsonResponse["message"] ?? "Gagal memproses pindah balita");
      }
    } catch (e) {
      return Left("Kesalahan: $e");
    }
  }

  // AUTO lulus
  Future<Either<String, String>> autoLulus(String nik) async {
    try {
      final response = await _service.post("kelulusan/$nik/auto", {});
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse["success"] == true) {
        return Right(jsonResponse["message"]);
      } else {
        return Left(jsonResponse["message"] ?? "Gagal meluluskan balita");
      }
    } catch (e) {
      return Left("Kesalahan: $e");
    }
  }
}
