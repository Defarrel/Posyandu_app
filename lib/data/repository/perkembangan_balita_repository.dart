import 'dart:convert';
import 'dart:developer';
import 'package:posyandu_app/data/models/request/perkembangan_balita/perkembangan_request_model.dart';
import 'package:posyandu_app/data/models/response/perkembangan_balita/perkembangan_attention_response.dart';
import 'package:posyandu_app/data/models/response/perkembangan_balita/perkembangan_balita_reponse.dart';
import 'package:posyandu_app/data/models/response/perkembangan_balita/skdn_response_model.dart';
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

  Future<Either<String, List<dynamic>>> getDetailPerkembanganBulanan({
    required int bulan,
    required int tahun,
  }) async {
    try {
      final response = await _service.get(
        "report/bulanan/detail?bulan=$bulan&tahun=$tahun",
      );
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse is Map<String, dynamic> &&
            jsonResponse['success'] == true &&
            jsonResponse['data'] is List) {
          return Right(jsonResponse['data']);
        } else {
          return Left("Format data detail tidak sesuai");
        }
      } else {
        return Left(
          (jsonResponse is Map && jsonResponse['message'] != null)
              ? jsonResponse['message']
              : "Gagal mengambil data detail perkembangan",
        );
      }
    } catch (e) {
      log("Exception getDetailPerkembanganBulanan: $e");
      return Left("Terjadi kesalahan saat mengambil data detail perkembangan");
    }
  }

  Future<Either<String, List<dynamic>>> getLaporanKhusus({
    required int bulan,
    required int tahun,
  }) async {
    try {
      final response = await _service.get(
        "report/laporan/khusus?bulan=$bulan&tahun=$tahun",
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse is Map<String, dynamic> &&
            jsonResponse['success'] == true &&
            jsonResponse['data'] is List) {
          return Right(jsonResponse['data']);
        } else {
          return Left("Format data laporan khusus tidak sesuai");
        }
      } else {
        return Left(
          (jsonResponse is Map && jsonResponse['message'] != null)
              ? jsonResponse['message']
              : "Gagal mengambil data laporan khusus",
        );
      }
    } catch (e) {
      log("Exception getLaporanKhusus: $e");
      return Left("Terjadi kesalahan saat mengambil laporan khusus");
    }
  }

  Future<Either<String, bool>> cekPerkembanganBulanIni({
    required String nikBalita,
  }) async {
    try {
      final now = DateTime.now();
      final bulan = now.month;
      final tahun = now.year;

      final response = await _service.get(
        "perkembangan/cek?nik=$nikBalita&bulan=$bulan&tahun=$tahun",
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse is Map &&
            jsonResponse["success"] == true &&
            jsonResponse.containsKey("sudah_input")) {
          return Right(jsonResponse["sudah_input"] == true);
        } else {
          return Left("Format data tidak sesuai dari server");
        }
      } else {
        return Left(
          jsonResponse["message"] ?? "Gagal mengecek data perkembangan",
        );
      }
    } catch (e) {
      log("Exception cekPerkembanganBulanIni: $e");
      return Left("Terjadi kesalahan saat mengecek data perkembangan");
    }
  }

  Future<Either<String, List<PerkembanganAttentionResponse>>>
  getBalitaPerluPerhatian() async {
    try {
      final response = await _service.get("perkembangan/perlu-diperhatikan");
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List data = jsonResponse["data"];
        return Right(
          data.map((e) => PerkembanganAttentionResponse.fromMap(e)).toList(),
        );
      }

      return Left(jsonResponse["message"] ?? "Gagal memuat data");
    } catch (e) {
      return Left("Kesalahan: $e");
    }
  }

  // SKDN
  Future<Either<String, SkdnResponseModel>> getSKDN({
    required int bulan,
    required int tahun,
  }) async {
    try {
      final response = await _service.get(
        "perkembangan/skdn?bulan=$bulan&tahun=$tahun",
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return Right(SkdnResponseModel.fromMap(data));
      } else {
        return Left(data['message'] ?? 'Gagal memuat SKDN');
      }
    } catch (e) {
      return Left("Kesalahan: $e");
    }
  }

// Detail Gizi
  Future<Either<String, List<Map<String, dynamic>>>> getDetailGiziKategori({
    required int bulan,
    required int tahun,
    required String kategori,
  }) async {
    try {
      String kategoriApi = '';
      switch (kategori.toLowerCase()) {
        case 'gizi buruk':
          kategoriApi = 'buruk';
          break;
        case 'gizi kurang':
          kategoriApi = 'kurang';
          break;
        case 'gizi normal':
          kategoriApi = 'normal';
          break;
        case 'risiko gizi lebih':
          kategoriApi = 'lebih';
          break;
        case 'obesitas':
          kategoriApi = 'obesitas';
          break;
        default:
          kategoriApi = 'normal';
      }

      final endpoint =
          "perkembangan/list-kategori?bulan=$bulan&tahun=$tahun&kategori=$kategoriApi";

      final response = await _service.get(endpoint);
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
          final List<dynamic> rawData = jsonResponse['data'];
          // Convert List<dynamic> ke List<Map<String, dynamic>>
          return Right(List<Map<String, dynamic>>.from(rawData));
        } else {
          return Left("Format data list kategori tidak sesuai");
        }
      } else {
        return Left(
          jsonResponse['message'] ?? "Gagal mengambil data detail gizi",
        );
      }
    } catch (e) {
      log("Exception getDetailGiziKategori: $e");
      return Left("Terjadi kesalahan saat mengambil detail gizi");
    }
  }
}
