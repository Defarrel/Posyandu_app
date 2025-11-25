import 'dart:convert';

class PerkembanganAttentionResponse {
  final String nik;
  final String nama;
  final String kms; 
  final String tanggalTerakhir;

  final String? alasan;
  final int? prioritas;

  PerkembanganAttentionResponse({
    required this.nik,
    required this.nama,
    required this.kms,
    required this.tanggalTerakhir,
    this.alasan,
    this.prioritas,
  });

  factory PerkembanganAttentionResponse.fromJson(String str) =>
      PerkembanganAttentionResponse.fromMap(json.decode(str));

  factory PerkembanganAttentionResponse.fromMap(Map<String, dynamic> map) {
    return PerkembanganAttentionResponse(
      nik: map["nik"] ?? "",
      nama: map["nama"] ?? map["nama_balita"] ?? "",
      kms: map["kms"] ?? "tidak_diketahui",
      tanggalTerakhir: map["tanggal_terakhir"] ??
          map["tanggal_perubahan"] ??
          "",
      alasan: map["alasan"],
      prioritas: map["prioritas"],
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {
        "nik": nik,
        "nama": nama,
        "kms": kms,
        "tanggal_terakhir": tanggalTerakhir,
        "alasan": alasan,
        "prioritas": prioritas,
      };
}
