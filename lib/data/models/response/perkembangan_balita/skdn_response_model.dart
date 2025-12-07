class SkdnResponseModel {
  final int bulan;
  final int tahun;
  final int s;
  final int k;
  final int d;
  final int n;
  final int jumlahLulus;
  final int jumlahS36;
  final PersentaseModel persentase;

  SkdnResponseModel({
    required this.bulan,
    required this.tahun,
    required this.s,
    required this.k,
    required this.d,
    required this.n,
    required this.jumlahLulus,
    required this.jumlahS36,
    required this.persentase,
  });

  factory SkdnResponseModel.fromMap(Map<String, dynamic> json) {
    return SkdnResponseModel(
      bulan: int.tryParse(json['bulan']?.toString() ?? '0') ?? 0,
      tahun: int.tryParse(json['tahun']?.toString() ?? '0') ?? 0,
      s: int.tryParse(json['S']?.toString() ?? '0') ?? 0,
      k: int.tryParse(json['K']?.toString() ?? '0') ?? 0,
      d: int.tryParse(json['D']?.toString() ?? '0') ?? 0,
      n: int.tryParse(json['N']?.toString() ?? '0') ?? 0,
      jumlahLulus: int.tryParse(json['jumlah_lulus']?.toString() ?? '0') ?? 0,
      jumlahS36: int.tryParse(json['jumlah_s_36']?.toString() ?? '0') ?? 0,
      persentase: PersentaseModel.fromMap(json['persentase'] ?? {}),
    );
  }
}

class PersentaseModel {
  final String kS;
  final String dS;
  final String nD;
  final String nS;

  PersentaseModel({
    required this.kS,
    required this.dS,
    required this.nD,
    required this.nS,
  });

  factory PersentaseModel.fromMap(Map<String, dynamic> json) {
    return PersentaseModel(
      kS: json['K_S']?.toString() ?? "0",
      dS: json['D_S']?.toString() ?? "0",
      nD: json['N_D']?.toString() ?? "0",
      nS: json['N_S']?.toString() ?? "0",
    );
  }
}
