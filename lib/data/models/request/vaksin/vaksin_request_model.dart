class VaksinRequestModel {
  final int vaksinId;
  final String nikBalita;
  final String tanggalPemberian;
  final String catatan;

  VaksinRequestModel({
    required this.vaksinId,
    required this.nikBalita,
    required this.tanggalPemberian,
    required this.catatan,
  });

  Map<String, dynamic> toJson() {
    return {
      "vaksin_id": vaksinId,
      "nik_balita": nikBalita,
      "tanggal_pemberian": tanggalPemberian,
      "catatan": catatan,
    };
  }
}
