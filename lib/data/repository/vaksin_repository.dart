import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:posyandu_app/data/models/request/vaksin/vaksin_request_model.dart';
import 'package:posyandu_app/data/models/response/vaksin/vaksin_respone_model.dart';
import 'package:posyandu_app/services/services_http_client.dart';

class VaksinRepository {
  final ServiceHttpClient _service = ServiceHttpClient();

  // GET daftar master vaksin
  Future<Either<String, List<VaksinMasterModel>>> getVaksinMaster() async {
    try {
      final response = await _service.get("vaksin/master");
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final List data = jsonResponse["data"];
        return Right(data.map((e) => VaksinMasterModel.fromJson(e)).toList());
      } else {
        return Left(jsonResponse["message"] ?? "Gagal memuat data vaksin");
      }
    } catch (e) {
      return Left("Kesalahan: $e");
    }
  }

  // GET detail vaksin balita dengan progress
  Future<Either<String, VaksinDetailResponseModel>> getVaksinBalita(
    String nik,
  ) async {
    try {
      final response = await _service.get("vaksin/riwayat/$nik");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true) {
          return Right(VaksinDetailResponseModel.fromJson(jsonResponse));
        } else {
          return Left(
            jsonResponse["message"] ?? "Gagal memuat data vaksin balita",
          );
        }
      } else {
        final jsonResponse = jsonDecode(response.body);
        return Left(jsonResponse["message"] ?? "Terjadi kesalahan server");
      }
    } catch (e) {
      return Left("Kesalahan: $e");
    }
  }

  // GET rekomendasi vaksin selanjutnya
  Future<Either<String, VaksinRekomendasiResponseModel>> getRekomendasiVaksin(
    String nik,
  ) async {
    try {
      final response = await _service.get("vaksin/rekomendasi/$nik");
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return Right(VaksinRekomendasiResponseModel.fromJson(jsonResponse));
      } else {
        return Left(
          jsonResponse["message"] ?? "Gagal memuat rekomendasi vaksin",
        );
      }
    } catch (e) {
      return Left("Kesalahan: $e");
    }
  }

  // POST Tambah vaksin balita
  Future<Either<String, String>> tambahVaksin(VaksinRequestModel model) async {
    try {
      final response = await _service.postWithToken(
        "vaksin/balita",
        model.toJson(),
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

  // PUT Update vaksin balita
  Future<Either<String, String>> updateVaksin(
    int id,
    VaksinRequestModel model,
  ) async {
    try {
      final response = await _service.put("vaksin/balita/$id", model.toJson());
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return Right(
          jsonResponse["message"] ?? "Data vaksin berhasil diupdate",
        );
      } else {
        return Left(jsonResponse["message"] ?? "Gagal mengupdate vaksin");
      }
    } catch (e) {
      return Left("Kesalahan: $e");
    }
  }

  // DELETE Hapus vaksin balita
  Future<Either<String, String>> deleteVaksin(int id) async {
    try {
      final response = await _service.delete("vaksin/balita/$id");
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
