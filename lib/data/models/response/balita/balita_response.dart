import 'dart:convert';

class BalitaResponseModel {
  final String nikBalita;
  final String namaBalita;
  final String jenisKelamin;
  final String tanggalLahir;
  final String anakKeBerapa;
  final String nomorKk;
  final String namaOrtu;
  final String nikOrtu;
  final String nomorTelpOrtu;
  final String alamat;
  final String rt;
  final String rw;
  final String createdAt;

  BalitaResponseModel({
    required this.nikBalita,
    required this.namaBalita,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.anakKeBerapa,
    required this.nomorKk,
    required this.namaOrtu,
    required this.nikOrtu,
    required this.nomorTelpOrtu,
    required this.alamat,
    required this.rt,
    required this.rw,
    required this.createdAt,
  });

  factory BalitaResponseModel.fromJson(String str) =>
      BalitaResponseModel.fromMap(json.decode(str));

  factory BalitaResponseModel.fromMap(Map<String, dynamic> map) =>
      BalitaResponseModel(
        nikBalita: map['nik_balita'],
        namaBalita: map['nama_balita'],
        jenisKelamin: map['jenis_kelamin'],
        tanggalLahir: map['tanggal_lahir'],
        anakKeBerapa: map['anak_ke_berapa'],
        nomorKk: map['nomor_kk'],
        namaOrtu: map['nama_ortu'],
        nikOrtu: map['nik_ortu'],
        nomorTelpOrtu: map['nomor_telp_ortu'],
        alamat: map['alamat'],
        rt: map['rt'],
        rw: map['rw'],
        createdAt: map['created_at'],
      );

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {
        "nik_balita": nikBalita,
        "nama_balita": namaBalita,
        "jenis_kelamin": jenisKelamin,
        "tanggal_lahir": tanggalLahir,
        "anak_ke_berapa": anakKeBerapa,
        "nomor_kk": nomorKk,
        "nama_ortu": namaOrtu,
        "nik_ortu": nikOrtu,
        "nomor_telp_ortu": nomorTelpOrtu,
        "alamat": alamat,
        "rt": rt,
        "rw": rw,
        "created_at": createdAt,
      };
}
