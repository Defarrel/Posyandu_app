class KelulusanDetailResponse {
  final String status;
  final String? tanggalLulus;
  final ProgressVaksin vaksin;
  final ProgressUmur umur;
  final bool siapLulus;

  KelulusanDetailResponse({
    required this.status,
    required this.tanggalLulus,
    required this.vaksin,
    required this.umur,
    required this.siapLulus,
  });

  factory KelulusanDetailResponse.fromJson(Map<String, dynamic> json) {
    return KelulusanDetailResponse(
      status: json["status"] ?? "BELUM LULUS",
      tanggalLulus: json["tanggal_lulus"],
      vaksin: ProgressVaksin.fromJson(json["vaksin"]),
      umur: ProgressUmur.fromJson(json["umur"]),
      siapLulus: json["siap_lulus"] ?? false,
    );
  }
}

class ProgressVaksin {
  final int totalVaksin;
  final int sudahDiambil;
  final double progressVaksin;

  ProgressVaksin({
    required this.totalVaksin,
    required this.sudahDiambil,
    required this.progressVaksin,
  });

  factory ProgressVaksin.fromJson(Map<String, dynamic> json) {
    return ProgressVaksin(
      totalVaksin: json["total_vaksin"] ?? 0,
      sudahDiambil: json["sudah_diambil"] ?? 0,
      progressVaksin:
          (json["progress_vaksin"] ?? 0).toDouble(),
    );
  }
}

class ProgressUmur {
  final int umurBulan;
  final double progressUmur;

  ProgressUmur({
    required this.umurBulan,
    required this.progressUmur,
  });

  factory ProgressUmur.fromJson(Map<String, dynamic> json) {
    return ProgressUmur(
      umurBulan: json["umur_bulan"] ?? 0,
      progressUmur: (json["progress_umur"] ?? 0).toDouble(),
    );
  }
}


// List Semua Balita + Status
class KelulusanListResponse {
  final int total;
  final List<KelulusanItem> data;

  KelulusanListResponse({
    required this.total,
    required this.data,
  });

  factory KelulusanListResponse.fromJson(Map<String, dynamic> json) {
    return KelulusanListResponse(
      total: json["total"] ?? 0,
      data: (json["data"] as List<dynamic>)
          .map((e) => KelulusanItem.fromJson(e))
          .toList(),
    );
  }
}

class KelulusanItem {
  final String nikBalita;
  final String namaBalita;
  final String tanggalLahir;
  final int umurBulan;
  final double progressVaksin;
  final double progressUmur;
  final String status;

  KelulusanItem({
    required this.nikBalita,
    required this.namaBalita,
    required this.tanggalLahir,
    required this.umurBulan,
    required this.progressVaksin,
    required this.progressUmur,
    required this.status,
  });

  factory KelulusanItem.fromJson(Map<String, dynamic> json) {
    return KelulusanItem(
      nikBalita: json["nik_balita"] ?? "",
      namaBalita: json["nama_balita"] ?? "",
      tanggalLahir: json["tanggal_lahir"] ?? "",
      umurBulan: json["umur_bulan"] ?? 0,
      progressVaksin: (json["progress_vaksin"] ?? 0).toDouble(),
      progressUmur: (json["progress_umur"] ?? 0).toDouble(),
      status: json["status"] ?? "BELUM LULUS",
    );
  }
}
