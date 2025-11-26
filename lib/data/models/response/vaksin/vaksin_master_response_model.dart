class VaksinMasterResponseModel {
  final int id;
  final String kode;
  final String namaVaksin;
  final int usiaBulan;
  final String? keterangan;

  VaksinMasterResponseModel({
    required this.id,
    required this.kode,
    required this.namaVaksin,
    required this.usiaBulan,
    this.keterangan,
  });

  factory VaksinMasterResponseModel.fromJson(Map<String, dynamic> json) {
    return VaksinMasterResponseModel(
      id: json["id"],
      kode: json["kode"],
      namaVaksin: json["nama_vaksin"],
      usiaBulan: json["usia_bulan"],
      keterangan: json["keterangan"],
    );
  }
}
