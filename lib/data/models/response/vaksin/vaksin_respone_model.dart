class VaksinMasterModel {
  final int id;
  final String namaVaksin;
  final String usiaBulan;

  VaksinMasterModel({
    required this.id,
    required this.namaVaksin,
    required this.usiaBulan,
  });

  factory VaksinMasterModel.fromJson(Map<String, dynamic> json) {
    return VaksinMasterModel(
      id: json["id"],
      namaVaksin: json["nama_vaksin"],
      usiaBulan: json["usia_bulan"],
    );
  }
}

class VaksinRiwayatModel {
  final int id;
  final int vaksinId;
  final String namaVaksin;
  final String tanggalPemberian;
  final String catatan;

  VaksinRiwayatModel({
    required this.id,
    required this.vaksinId,
    required this.namaVaksin,
    required this.tanggalPemberian,
    required this.catatan,
  });

  factory VaksinRiwayatModel.fromJson(Map<String, dynamic> json) {
    return VaksinRiwayatModel(
      id: json["id"],
      vaksinId: json["vaksin_id"],
      namaVaksin: json["nama_vaksin"] ?? "",
      tanggalPemberian: json["tanggal_pemberian"],
      catatan: json["catatan"] ?? "-",
    );
  }
}
