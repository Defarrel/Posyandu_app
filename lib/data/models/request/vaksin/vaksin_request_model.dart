class VaksinRequestModel {
  final String nik_balita;
  final int vaksin_id;
  final String tanggal;
  final String? petugas;
  final String? batch_no;
  final String? lokasi;

  VaksinRequestModel({
    required this.nik_balita,
    required this.vaksin_id,
    required this.tanggal,
    this.petugas,
    this.batch_no,
    this.lokasi,
  });

  Map<String, dynamic> toJson() {
    return {
      'nik_balita': nik_balita,
      'vaksin_id': vaksin_id,
      'tanggal': tanggal,
      if (petugas != null && petugas!.isNotEmpty) 'petugas': petugas,
      if (batch_no != null && batch_no!.isNotEmpty) 'batch_no': batch_no,
      if (lokasi != null && lokasi!.isNotEmpty) 'lokasi': lokasi,
    };
  }
}