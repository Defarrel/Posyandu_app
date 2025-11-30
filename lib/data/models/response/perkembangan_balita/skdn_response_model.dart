class SkdnResponseModel {
  final int bulan;
  final int tahun;
  final int s;
  final int k;
  final int d;
  final int n;
  final PersentaseModel persentase;

  SkdnResponseModel({
    required this.bulan,
    required this.tahun,
    required this.s,
    required this.k,
    required this.d,
    required this.n,
    required this.persentase,
  });

  factory SkdnResponseModel.fromMap(Map<String, dynamic> json) {
    return SkdnResponseModel(
      bulan: json['bulan'] ?? 0,
      tahun: json['tahun'] ?? 0,
      s: json['S'] ?? 0, // Huruf besar sesuai response backend nodejs
      k: json['K'] ?? 0,
      d: json['D'] ?? 0,
      n: json['N'] ?? 0,
      persentase: PersentaseModel.fromMap(json['persentase'] ?? {}),
    );
  }
}

class PersentaseModel {
  final String kS;
  final String dS;
  final String nD;

  PersentaseModel({required this.kS, required this.dS, required this.nD});

  factory PersentaseModel.fromMap(Map<String, dynamic> json) {
    return PersentaseModel(
      // Backend mengirim key dengan format "K_S", "D_S", "N_D"
      kS: json['K_S']?.toString() ?? "0",
      dS: json['D_S']?.toString() ?? "0",
      nD: json['N_D']?.toString() ?? "0",
    );
  }
}
