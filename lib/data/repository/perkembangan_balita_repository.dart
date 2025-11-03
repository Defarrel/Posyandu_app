import 'dart:convert';
import 'dart:developer';
import 'package:posyandu_app/data/models/request/perkembangan_balita/perkembangan_request_model.dart';
import 'package:posyandu_app/data/models/response/perkembangan_balita/perkembangan_balita_reponse.dart';
import 'package:posyandu_app/services/services_http_client.dart';
import 'package:dartz/dartz.dart';

class PerkembanganBalitaRepository {
  final ServiceHttpClient _service = ServiceHttpClient();

  Future<Either<String, String>> tambahPerkembangan(
    PerkembanganBalitaRequestModel requestModel,
  ) async {
    try {
      final response = await _service.postWithToken(
        "perkembangan",
        requestModel.toMap(),
      );
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 201) {
        return Right(
          jsonResponse['message'] ?? "Data perkembangan berhasil ditambahkan",
        );
      } else {
        return Left(
          jsonResponse['message'] ?? "Gagal menambahkan data perkembangan",
        );
      }
    } catch (e) {
      log("Exception tambahPerkembangan: $e");
      return Left("Terjadi kesalahan saat menambahkan data perkembangan");
    }
  }

  Future<Either<String, List<PerkembanganBalitaResponseModel>>>
  getPerkembangan() async {
    try {
      final response = await _service.get("perkembangan");
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonResponse;
        final result = list
            .map((e) => PerkembanganBalitaResponseModel.fromMap(e))
            .toList();
        return Right(result);
      } else {
        return Left(
          jsonResponse['message'] ?? "Gagal mengambil data perkembangan",
        );
      }
    } catch (e) {
      log("Exception getPerkembangan: $e");
      return Left("Terjadi kesalahan saat mengambil data perkembangan");
    }
  }

  Future<Either<String, List<PerkembanganBalitaResponseModel>>>
  getPerkembanganByNIK(String nik) async {
    try {
      final response = await _service.get("perkembangan/$nik");
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonResponse;
        final result = list
            .map((e) => PerkembanganBalitaResponseModel.fromMap(e))
            .toList();
        return Right(result);
      } else if (response.statusCode == 404) {
        return Left(jsonResponse['message'] ?? "Data tidak ditemukan");
      } else {
        return Left(
          jsonResponse['message'] ?? "Gagal mengambil data perkembangan",
        );
      }
    } catch (e) {
      log("Exception getPerkembanganByNIK: $e");
      return Left("Terjadi kesalahan saat mengambil data perkembangan");
    }
  }

  Future<Either<String, String>> updatePerkembangan(
    int id,
    PerkembanganBalitaRequestModel requestModel,
  ) async {
    try {
      final response = await _service.put(
        "perkembangan/$id",
        requestModel.toMap(),
      );
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return Right(
          jsonResponse['message'] ?? "Data perkembangan berhasil diperbarui",
        );
      } else {
        return Left(
          jsonResponse['message'] ?? "Gagal memperbarui data perkembangan",
        );
      }
    } catch (e) {
      log("Exception updatePerkembangan: $e");
      return Left("Terjadi kesalahan saat memperbarui data perkembangan");
    }
  }

  Future<Either<String, String>> deletePerkembangan(int id) async {
    try {
      final response = await _service.delete("perkembangan/$id");
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return Right(
          jsonResponse['message'] ?? "Data perkembangan berhasil dihapus",
        );
      } else {
        return Left(
          jsonResponse['message'] ?? "Gagal menghapus data perkembangan",
        );
      }
    } catch (e) {
      log("Exception deletePerkembangan: $e");
      return Left("Terjadi kesalahan saat menghapus data perkembangan");
    }
  }

  Future<Either<String, Map<String, dynamic>>> getStatistikPerkembangan({
    required int bulan,
    int? tahun,
  }) async {
    try {
      final endpoint = tahun != null
          ? "perkembangan/statistik/bulan?bulan=$bulan&tahun=$tahun"
          : "perkembangan/statistik/bulan?bulan=$bulan";

      final response = await _service.get(endpoint);
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse is Map<String, dynamic>) {
          return Right(jsonResponse);
        } else {
          return Left("Format data dari server tidak sesuai");
        }
      } else {
        return Left(
          (jsonResponse is Map && jsonResponse['message'] != null)
              ? jsonResponse['message']
              : "Gagal mengambil data statistik",
        );
      }
    } catch (e) {
      log("Exception getStatistikPerkembangan: $e");
      return Left("Terjadi kesalahan saat mengambil data statistik");
    }
  }
}
