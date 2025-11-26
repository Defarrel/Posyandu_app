class VaksinMasterRequestModel {
  final String kode;
  final String namaVaksin;
  final int usiaBulan;
  final String? keterangan;

  VaksinMasterRequestModel({
    required this.kode,
    required this.namaVaksin,
    required this.usiaBulan,
    this.keterangan,
  });

  Map<String, dynamic> toJson() {
    return {
      "kode": kode,
      "nama_vaksin": namaVaksin,
      "usia_bulan": usiaBulan,
      "keterangan": keterangan,
    };
  }
}
