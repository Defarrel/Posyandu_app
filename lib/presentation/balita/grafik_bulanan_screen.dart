import 'package:flutter/material.dart';
import 'package:posyandu_app/core/components/custom_dropdown_button.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/repository/perkembangan_balita_repository.dart';

class GrafikBulananScreen extends StatefulWidget {
  const GrafikBulananScreen({super.key});

  @override
  State<GrafikBulananScreen> createState() => _GrafikBulananScreenState();
}

class _GrafikBulananScreenState extends State<GrafikBulananScreen> {
  final PerkembanganBalitaRepository _repository =
      PerkembanganBalitaRepository();

  final List<String> _bulanList = const [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  late String _bulanDipilih;
  late int _tahunDipilih;
  late List<int> _tahunList;

  bool _isLoadingChart = true;
  int _normal = 0;
  int _kurang = 0;
  int _obesitas = 0;
  int _lakiNormal = 0;
  int _lakiKurang = 0;
  int _lakiObesitas = 0;
  int _perempuanNormal = 0;
  int _perempuanKurang = 0;
  int _perempuanObesitas = 0;
  int _totalLaki = 0;
  int _totalPerempuan = 0;

  @override
  void initState() {
    super.initState();
    _bulanDipilih = _bulanList[DateTime.now().month - 1];
    _tahunDipilih = DateTime.now().year;
    _tahunList = List.generate(5, (i) => DateTime.now().year - i);
    _fetchStatistik();
  }

  Future<void> _fetchStatistik() async {
    setState(() => _isLoadingChart = true);
    final bulanIndex = _bulanList.indexOf(_bulanDipilih) + 1;

    final result = await _repository.getStatistikPerkembangan(
      bulan: bulanIndex,
      tahun: _tahunDipilih,
    );

    result.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data grafik: $error")),
        );
        setState(() => _isLoadingChart = false);
      },
      (data) {
        try {
          final laki = (data['laki_laki'] ?? {}) as Map<String, dynamic>;
          final perempuan = (data['perempuan'] ?? {}) as Map<String, dynamic>;

          setState(() {
            // Ambil langsung dari API tanpa perhitungan
            _normal = (data['normal'] ?? 0) as int;
            _kurang = (data['kurang'] ?? 0) as int;
            _obesitas = (data['obesitas'] ?? 0) as int;
            _totalLaki = (data['total_laki'] ?? 0) as int;
            _totalPerempuan = (data['total_perempuan'] ?? 0) as int;

            _lakiNormal = (laki['normal'] ?? 0) as int;
            _lakiKurang = (laki['kurang'] ?? 0) as int;
            _lakiObesitas = (laki['obesitas'] ?? 0) as int;

            _perempuanNormal = (perempuan['normal'] ?? 0) as int;
            _perempuanKurang = (perempuan['kurang'] ?? 0) as int;
            _perempuanObesitas = (perempuan['obesitas'] ?? 0) as int;

            _isLoadingChart = false;
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Format data tidak sesuai struktur API baru: $e"),
            ),
          );
          setState(() => _isLoadingChart = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<_GrafikData> chartData = [
      _GrafikData('Obesitas', _obesitas, Colors.redAccent),
      _GrafikData('Kurang', _kurang, Colors.orangeAccent),
      _GrafikData('Normal', _normal, Colors.green),
    ];

    final total = _normal + _kurang + _obesitas;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Grafik Perkembangan Balita",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.primary,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchStatistik,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Grafik Balita Bulan ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomDropdownButton(
                                value: _bulanDipilih ?? _bulanList.first,
                                items: _bulanList,
                                isCompact: true,
                                textColor: Colors.white,
                                onChanged: (value) async {
                                  setState(() => _bulanDipilih = value ?? '');
                                  await _fetchStatistik();
                                },
                              ),
                              const SizedBox(width: 4),
                              CustomDropdownButton(
                                value: _tahunDipilih.toString(),
                                items: _tahunList
                                    .map((t) => t.toString())
                                    .toList(),
                                isCompact: true,
                                textColor: Colors.white,
                                onChanged: (value) async {
                                  setState(
                                    () => _tahunDipilih =
                                        int.tryParse(value ?? '') ??
                                        DateTime.now().year,
                                  );
                                  await _fetchStatistik();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _isLoadingChart
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            )
                          : SfCartesianChart(
                              plotAreaBorderWidth: 0,
                              primaryXAxis: CategoryAxis(
                                labelStyle: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              primaryYAxis: NumericAxis(
                                labelStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                axisLine: const AxisLine(width: 0),
                                majorGridLines: const MajorGridLines(
                                  color: Colors.grey,
                                  width: 0.3,
                                ),
                                interval: 1,
                              ),
                              tooltipBehavior: TooltipBehavior(enable: true),
                              series: <CartesianSeries<_GrafikData, String>>[
                                ColumnSeries<_GrafikData, String>(
                                  dataSource: chartData,
                                  xValueMapper: (data, _) => data.kategori,
                                  yValueMapper: (data, _) => data.jumlah,
                                  pointColorMapper: (data, _) => data.warna,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(2),
                                  ),
                                  width: 0.5,
                                  dataLabelSettings: const DataLabelSettings(
                                    isVisible: true,
                                    labelAlignment:
                                        ChartDataLabelAlignment.middle,
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Detail Grafik",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Table(
                            border: TableBorder.all(
                              color: Colors.grey.shade300,
                            ),
                            children: [
                              _buildRow([
                                "Status Gizi",
                                "Laki-laki",
                                "Perempuan",
                                "Total",
                              ], isHeader: true),
                              _buildRow([
                                "Normal",
                                "${_lakiNormal}",
                                "${_perempuanNormal}",
                                "${_normal}",
                              ]),
                              _buildRow([
                                "Kurang",
                                "${_lakiKurang}",
                                "${_perempuanKurang}",
                                "${_kurang}",
                              ]),
                              _buildRow([
                                "Obesitas",
                                "${_lakiObesitas}",
                                "${_perempuanObesitas}",
                                "${_obesitas}",
                              ]),
                              _buildRow([
                                "Total",
                                "${_totalLaki}",
                                "${_totalPerempuan}",
                                "$total",
                              ], isHeader: true),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Ringkasan Pertumbuhan Balita – $_bulanDipilih",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Total balita: $total anak\n"
                            "• Laki-laki: $_totalLaki anak\n"
                            "• Perempuan: $_totalPerempuan anak\n\n"
                            "• Normal: $_normal anak\n"
                            "• Kurang: $_kurang anak\n"
                            "• Obesitas: $_obesitas anak\n\n"
                            "Mayoritas balita dalam kategori gizi normal. "
                            "Namun, ${(100 - (_normal / (total == 0 ? 1 : total) * 100)).toStringAsFixed(1)}% anak "
                            "masih mengalami masalah gizi yang perlu perhatian lebih lanjut.",
                            style: const TextStyle(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tombol Cetak
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Fitur cetak laporan belum tersedia"),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Cetak Laporan",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildRow(List<String> data, {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(color: isHeader ? Colors.grey.shade100 : null),
      children: data.map((text) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _GrafikData {
  final String kategori;
  final int jumlah;
  final Color warna;
  _GrafikData(this.kategori, this.jumlah, this.warna);
}
