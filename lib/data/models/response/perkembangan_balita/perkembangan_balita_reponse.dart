import 'dart:convert';

class PerkembanganBalitaResponseModel {
  final int id;
  final String nikBalita;
  final double lingkarLengan;
  final double lingkarKepala;
  final double tinggiBadan;
  final double beratBadan;
  final String caraUkur;
  final String vitaminA;
  final String kms;
  final String imd;
  final String asiEks;
  final String tanggalPerubahan;
  final String createdAt;

  PerkembanganBalitaResponseModel({
    required this.id,
    required this.nikBalita,
    required this.lingkarLengan,
    required this.lingkarKepala,
    required this.tinggiBadan,
    required this.beratBadan,
    required this.caraUkur,
    required this.vitaminA,
    required this.kms,
    required this.imd,
    required this.asiEks,
    required this.tanggalPerubahan,
    required this.createdAt,
  });

  factory PerkembanganBalitaResponseModel.fromJson(String str) =>
      PerkembanganBalitaResponseModel.fromMap(json.decode(str));

  factory PerkembanganBalitaResponseModel.fromMap(Map<String, dynamic> map) =>
      PerkembanganBalitaResponseModel(
        id: map['id'],
        nikBalita: map['nik_balita'],
        lingkarLengan: map['lingkar_lengan']?.toDouble(),
        lingkarKepala: map['lingkar_kepala']?.toDouble(),
        tinggiBadan: map['tinggi_badan']?.toDouble(),
        beratBadan: map['berat_badan']?.toDouble(),
        caraUkur: map['cara_ukur'],
        vitaminA: map['vitamin_a'],
        kms: map['kms'],
        imd: map['imd'],
        asiEks: map['asi_eks'],
        tanggalPerubahan: map['tanggal_perubahan'],
        createdAt: map['created_at'],
      );

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {
    "id": id,
    "nik_balita": nikBalita,
    "lingkar_lengan": lingkarLengan,
    "lingkar_kepala": lingkarKepala,
    "tinggi_badan": tinggiBadan,
    "berat_badan": beratBadan,
    "cara_ukur": caraUkur,
    "vitamin_a": vitaminA,
    "kms": kms,
    "imd": imd,
    "asi_eks": asiEks,
    "tanggal_perubahan": tanggalPerubahan,
    "created_at": createdAt,
  };
}
