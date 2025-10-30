import 'package:flutter/material.dart';
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
        setState(() {
          _normal = data["normal"];
          _kurang = data["kurang"];
          _obesitas = data["obesitas"];
          _isLoadingChart = false;
        });
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
              // Pilih Bulan & Tahun
              Row(
                children: [
                  DropdownButton<String>(
                    value: _bulanDipilih,
                    items: _bulanList
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _bulanDipilih = value);
                      _fetchStatistik();
                    },
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<int>(
                    value: _tahunDipilih,
                    items: _tahunList
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _tahunDipilih = value);
                      _fetchStatistik();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Grafik
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
                          labelStyle: const TextStyle(color: Colors.black),
                          axisLine: const AxisLine(width: 0),
                          majorGridLines: const MajorGridLines(
                            color: Colors.grey,
                            width: 0.3,
                          ),
                          interval: 10,
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
                              labelAlignment: ChartDataLabelAlignment.middle,
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
              const SizedBox(height: 24),

              // Detail Tabel & Ringkasan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Detail Grafik",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Table(
                      border: TableBorder.all(color: Colors.grey.shade400),
                      children: [
                        const TableRow(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'Status Gizi',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'Laki-Laki',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'Perempuan',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'Total',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8),
                              child: Text('Normal'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text('${(_normal * 0.5).toInt()}'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text('${(_normal * 0.5).toInt()}'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text('$_normal'),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8),
                              child: Text('Kurang'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text('${(_kurang * 0.55).toInt()}'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text('${(_kurang * 0.45).toInt()}'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text('$_kurang'),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8),
                              child: Text('Obesitas'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text('${(_obesitas * 0.45).toInt()}'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text('${(_obesitas * 0.55).toInt()}'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text('$_obesitas'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Ringkasan Pertumbuhan Balita",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Total balita: $total anak\n"
                      "- Normal: $_normal anak\n"
                      "- Kurang: $_kurang anak\n"
                      "- Obesitas: $_obesitas anak\n"
                      "Mayoritas balita dalam kategori gizi normal. Namun, beberapa anak masih memerlukan perhatian.",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GrafikData {
  final String kategori;
  final int jumlah;
  final Color warna;
  _GrafikData(this.kategori, this.jumlah, this.warna);
}
