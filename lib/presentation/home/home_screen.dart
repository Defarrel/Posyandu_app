import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:posyandu_app/core/components/buttons.dart';
import 'package:posyandu_app/core/components/custom_dropdown_button.dart';
import 'package:posyandu_app/core/components/custom_appbar_home.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/repository/perkembangan_balita_repository.dart';
import 'package:posyandu_app/presentation/balita/grafik_bulanan_screen.dart';
import 'package:posyandu_app/presentation/balita/tambah_balita_screen.dart';
import 'package:posyandu_app/presentation/home/home_root.dart';
import 'package:posyandu_app/presentation/perkembanganBalita/cari_perkembangan_balita_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  String? _bulanDipilih;
  int? _tahunDipilih;
  late List<int> _tahunList;

  String _namaKader = "Memuat...";
  bool _isLoadingChart = true;

  static const double _curvedAppBarHeight = 230.0;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final PerkembanganBalitaRepository _repository =
      PerkembanganBalitaRepository();

  int _normal = 0;
  int _kurang = 0;
  int _obesitas = 0;

  @override
  void initState() {
    super.initState();
    _bulanDipilih = _bulanList[DateTime.now().month - 1];
    _tahunDipilih = DateTime.now().year;
    _tahunList = List.generate(5, (i) => DateTime.now().year - i);
    _loadNamaKader();
    _fetchStatistik();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadNamaKader() async {
    final nama = await _storage.read(key: 'username');
    setState(() {
      _namaKader = nama ?? "Kader";
    });
  }

  Future<void> _fetchStatistik() async {
    setState(() => _isLoadingChart = true);

    final bulanIndex =
        _bulanList.indexOf(_bulanDipilih ?? _bulanList.first) + 1;
    final tahun = _tahunDipilih ?? DateTime.now().year;

    final result = await _repository.getStatistikPerkembangan(
      bulan: bulanIndex,
      tahun: tahun,
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: CustomAppBarHome(nama: _namaKader, posyandu: "Posyandu Dahlia"),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _fetchStatistik,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              top: _curvedAppBarHeight + 10,
              bottom: 20,
            ),
            child: Column(
              children: [
                _buildGrafikCard(),
                const SizedBox(height: 20),
                _buildMenuSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrafikCard() {
    final List<_GrafikData> chartData = [
      _GrafikData('Obesitas', _obesitas, Colors.redAccent),
      _GrafikData('Kurang', _kurang, Colors.orangeAccent),
      _GrafikData('Normal', _normal, Colors.green),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
                          setState(() => _bulanDipilih = value);
                          await _fetchStatistik();
                        },
                      ),
                      const SizedBox(width: 4),
                      CustomDropdownButton(
                        value: _tahunDipilih.toString(),
                        items: _tahunList.map((t) => t.toString()).toList(),
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
                        labelStyle: const TextStyle(color: Colors.black),
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
                          animationDuration: 1500,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(2),
                          ),
                          width: 0.5,
                          dataSource: chartData,
                          xValueMapper: (data, _) => data.kategori,
                          yValueMapper: (data, _) => data.jumlah,
                          pointColorMapper: (data, _) => data.warna,
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
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const Text(
            'Menu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              MenuButton(
                title: "Tambah Balita\nBaru",
                imagePath: "lib/core/assets/tambahbalita.png",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TambahBalitaScreen()),
                ),
              ),
              MenuButton(
                title: "Tambah Data\nPerkembangan",
                imagePath: "lib/core/assets/perkembangan.png",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CariPerkembanganBalitaScreen(),
                  ),
                ),
              ),
              MenuButton(
                title: "Grafik Bulanan\nBalita",
                imagePath: "lib/core/assets/grafik.png",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GrafikBulananScreen(),
                  ),
                ),
              ),
              MenuButton(
                title: "Cari Data\nBalita",
                imagePath: "lib/core/assets/caridata.png",
                onTap: () => HomeRoot.navigateToTab(context, 0),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
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
