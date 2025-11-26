
class VaksinMasterModel {
  final int id;
  final String kode;
  final String namaVaksin;
  final int usiaBulan;
  final String? keterangan;

  VaksinMasterModel({
    required this.id,
    required this.kode,
    required this.namaVaksin,
    required this.usiaBulan,
    this.keterangan,
  });

  factory VaksinMasterModel.fromJson(Map<String, dynamic> json) {
    return VaksinMasterModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      kode: json['kode']?.toString() ?? '',
      namaVaksin: json['nama_vaksin']?.toString() ?? '',
      usiaBulan: json['usia_bulan'] is int
          ? json['usia_bulan']
          : int.tryParse(json['usia_bulan'].toString()) ?? 0,
      keterangan: json['keterangan']?.toString(),
    );
  }
}

class VaksinRiwayatModel {
  final int id;
  final int vaksinId;
  final String namaVaksin;
  final String kode;
  final int usiaBulan;
  final String tanggal;
  final String? petugas;
  final String? batchNo;
  final String? lokasi;

  VaksinRiwayatModel({
    required this.id,
    required this.vaksinId,
    required this.namaVaksin,
    required this.kode,
    required this.usiaBulan,
    required this.tanggal,
    this.petugas,
    this.batchNo,
    this.lokasi,
  });

  factory VaksinRiwayatModel.fromJson(Map<String, dynamic> json) {
    return VaksinRiwayatModel(
      id: json['id'] ?? 0,
      vaksinId: json['vaksin_id'] ?? 0,
      namaVaksin: json['nama_vaksin'] ?? '',
      kode: json['kode'] ?? '',
      usiaBulan: json['usia_bulan'] ?? 0,
      tanggal: json['tanggal'] ?? '',
      petugas: json['petugas'],
      batchNo: json['batch_no'],
      lokasi: json['lokasi'],
    );
  }

  String get tanggalPemberian => tanggal;

  String get catatan {
    List<String> info = [];
    if (batchNo != null && batchNo!.isNotEmpty) info.add('Batch: $batchNo');
    if (lokasi != null && lokasi!.isNotEmpty) info.add('Lokasi: $lokasi');
    if (petugas != null && petugas!.isNotEmpty) info.add('Petugas: $petugas');
    return info.join(', ');
  }
}

class VaksinDetailResponseModel {
  final int totalVaksin;
  final int sudahDiambil;
  final double progress;
  final List<VaksinRiwayatModel> data;

  VaksinDetailResponseModel({
    required this.totalVaksin,
    required this.sudahDiambil,
    required this.progress,
    required this.data,
  });

  factory VaksinDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return VaksinDetailResponseModel(
      totalVaksin: json['total_vaksin'] ?? 0,
      sudahDiambil: json['sudah_diambil'] ?? 0,
      progress: (json['progress'] ?? 0).toDouble(),
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => VaksinRiwayatModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class VaksinRekomendasiResponseModel {
  final int usiaBulan;
  final List<VaksinMasterModel> vaksinSelanjutnya;

  VaksinRekomendasiResponseModel({
    required this.usiaBulan,
    required this.vaksinSelanjutnya,
  });

  factory VaksinRekomendasiResponseModel.fromJson(Map<String, dynamic> json) {
    return VaksinRekomendasiResponseModel(
      usiaBulan: json['usia_bulan'] ?? 0,
      vaksinSelanjutnya: (json['vaksin_selanjutnya'] as List<dynamic>)
          .map((e) => VaksinMasterModel.fromJson(e))
          .toList(),
    );
  }
}
