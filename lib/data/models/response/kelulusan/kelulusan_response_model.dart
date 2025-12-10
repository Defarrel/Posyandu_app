class KelulusanDetailResponse {
  final String status;
  final String? keterangan;
  final String? tanggalLulus; 
  final KelulusanVaksinModel vaksin;
  final KelulusanUmurModel umur;
  final bool siapLulus;

  KelulusanDetailResponse({
    required this.status,
    this.keterangan,
    this.tanggalLulus,
    required this.vaksin,
    required this.umur,
    required this.siapLulus,
  });

  factory KelulusanDetailResponse.fromJson(Map<String, dynamic> json) {
    return KelulusanDetailResponse(
      status: json['status'] ?? "BELUM LULUS",
      keterangan: json['keterangan'],
      tanggalLulus: json['tanggal_lulus'],
      vaksin: KelulusanVaksinModel.fromJson(json['vaksin']),
      umur: KelulusanUmurModel.fromJson(json['umur']),
      siapLulus: json['siap_lulus'] ?? false,
    );
  }
}

class KelulusanVaksinModel {
  final int totalVaksin;
  final int sudahDiambil;
  final double progressVaksin;

  KelulusanVaksinModel({
    required this.totalVaksin,
    required this.sudahDiambil,
    required this.progressVaksin,
  });

  factory KelulusanVaksinModel.fromJson(Map<String, dynamic> json) {
    return KelulusanVaksinModel(
      totalVaksin: json['total_vaksin'] ?? 0,
      sudahDiambil: json['sudah_diambil'] ?? 0,
      progressVaksin: (json['progress_vaksin'] ?? 0).toDouble(),
    );
  }
}

class KelulusanUmurModel {
  final int umurBulan;
  final double progressUmur;

  KelulusanUmurModel({required this.umurBulan, required this.progressUmur});

  factory KelulusanUmurModel.fromJson(Map<String, dynamic> json) {
    return KelulusanUmurModel(
      umurBulan: json['umur_bulan'] ?? 0,
      progressUmur: (json['progress_umur'] ?? 0).toDouble(),
    );
  }
}

class KelulusanListResponse {
  final int total;
  final List<KelulusanListItem> data;

  KelulusanListResponse({required this.total, required this.data});

  factory KelulusanListResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<KelulusanListItem> dataList = list
        .map((i) => KelulusanListItem.fromJson(i))
        .toList();

    return KelulusanListResponse(total: json['total'] ?? 0, data: dataList);
  }
}

class KelulusanListItem {
  final String nikBalita;
  final String namaBalita;
  final String status;
  final int umurBulan;
  final double progressVaksin;

  KelulusanListItem({
    required this.nikBalita,
    required this.namaBalita,
    required this.status,
    required this.umurBulan,
    required this.progressVaksin,
  });

  factory KelulusanListItem.fromJson(Map<String, dynamic> json) {
    return KelulusanListItem(
      nikBalita: json['nik_balita'] ?? "",
      namaBalita: json['nama_balita'] ?? "",
      status: json['status'] ?? "BELUM LULUS",
      umurBulan: json['umur_bulan'] ?? 0,
      progressVaksin: (json['progress_vaksin'] ?? 0).toDouble(),
    );
  }
}
