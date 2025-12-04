class PerkembanganKhususItem {
  final String nik;
  final String noKk;
  final String nama;
  final String jenisKelamin;
  final String tanggalLahir;
  final String anakKe;
  final String namaOrtu;
  final String nikOrtu;
  final String nomorHpOrtu;
  final String alamat;
  final String rt;
  final String rw;

  final double bbBulanIni;
  final double tbBulanIni;
  final String caraUkur;
  final String kms;
  final String imd;
  final String asiEks;
  final String vitaminA;

  final String bbLahir;
  final String tbLahir;

  PerkembanganKhususItem({
    required this.nik,
    required this.noKk,
    required this.nama,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.anakKe,
    required this.namaOrtu,
    required this.nikOrtu,
    required this.nomorHpOrtu,
    required this.alamat,
    required this.rt,
    required this.rw,
    required this.bbBulanIni,
    required this.tbBulanIni,
    required this.caraUkur,
    required this.kms,
    required this.imd,
    required this.asiEks,
    required this.vitaminA,
    required this.bbLahir,
    required this.tbLahir,
  });

  factory PerkembanganKhususItem.fromJson(Map<String, dynamic> json) {
    return PerkembanganKhususItem(
      nik: json["nik"] ?? "-",
      noKk: json["no_kk"] ?? "-",
      nama: json["nama"] ?? "-",
      jenisKelamin: json["jenis_kelamin"] ?? "-",
      tanggalLahir: json["tanggal_lahir"] ?? "-",
      anakKe: json["anak_ke_berapa"]?.toString() ?? "-",
      namaOrtu: json["nama_ortu"] ?? "-",
      nikOrtu: json["nik_ortu"] ?? "-",
      nomorHpOrtu: json["nomor_telp_ortu"] ?? "-",
      alamat: json["alamat"] ?? "-",
      rt: json["rt"]?.toString() ?? "-",
      rw: json["rw"]?.toString() ?? "-",

      bbBulanIni: (json["bb_bulan_ini"] ?? 0).toDouble(),
      tbBulanIni: (json["tb_bulan_ini"] ?? 0).toDouble(),
      caraUkur: json["cara_ukur"] ?? "-",
      kms: json["kms"] ?? "-",
      imd: json["imd"] ?? "-",
      asiEks: json["asi_eks"] ?? "-",
      vitaminA: json["vitamin_a"] ?? "-",

      bbLahir: json["bb_lahir"]?.toString() ?? " ",
      tbLahir: json["tb_lahir"]?.toString() ?? " ",
    );
  }
}
