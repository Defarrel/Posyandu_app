class PerkembanganItem {
  final String nama;
  final String nik;
  final String jenisKelamin;
  final String tanggalLahir;
  final String anakKe;
  final String namaOrtu;
  final String nikOrtu;
  final String nomorHpOrtu;
  final String alamat;
  final String rt;
  final String rw;
  final Map<String, dynamic> perkembanganBulanan;

  PerkembanganItem({
    required this.nama,
    required this.nik,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.anakKe,
    required this.namaOrtu,
    required this.nikOrtu,
    required this.nomorHpOrtu,
    required this.alamat,
    required this.rt,
    required this.rw,
    required this.perkembanganBulanan,
  });

  double getBeratBadan(int bulan) =>
      (perkembanganBulanan[bulan.toString()]?['bb'] ?? 0.0).toDouble();

  double getTinggiBadan(int bulan) =>
      (perkembanganBulanan[bulan.toString()]?['tb'] ?? 0.0).toDouble();

  double getLingkarLengan(int bulan) =>
      (perkembanganBulanan[bulan.toString()]?['ll'] ?? 0.0).toDouble();

  double getLingkarKepala(int bulan) =>
      (perkembanganBulanan[bulan.toString()]?['lk'] ?? 0.0).toDouble();
}
