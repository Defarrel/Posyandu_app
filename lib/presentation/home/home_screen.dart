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
                const SizedBox(height: 20),
                _buildAdditionalMenuSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrafikCard() {
    final int totalBalita = _normal + _kurang + _obesitas;

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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.95),
              AppColors.accent,
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
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
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    letterSpacing: 0.3,
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

            const SizedBox(height: 16),

            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
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
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      primaryYAxis: NumericAxis(
                        labelStyle: const TextStyle(color: Colors.black87),
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
                          animationDuration: 1300,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          width: 0.55,
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

            const SizedBox(height: 14),

            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.group, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    "Total Balita: $totalBalita",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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
            'Menu Utama',
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
        ],
      ),
    );
  }

  Widget _buildAdditionalMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Text(
            'Menu Lainnya',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ModernMenuCard(
            title: "Vaksin Balita",
            subtitle: "Kelola jadwal dan riwayat vaksinasi",
            imagePath: "lib/core/assets/vaksin_balita.png",
            gradientColors: const [AppColors.primary, AppColors.accent],
            onTap: () {
              // TODO: Navigate to Vaksin Screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Menu Vaksin Balita")),
              );
            },
          ),
          const SizedBox(height: 16),
          ModernMenuCard(
            title: "Kelulusan Balita",
            subtitle: "Data balita yang telah lulus posyandu",
            imagePath: "lib/core/assets/kelulusan_balita.png",
            gradientColors: const [Color(0xFF0096FF), Color(0xFF00B4D8)],
            onTap: () {
              // TODO: Navigate to Kelulusan Screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Menu Kelulusan Balita")),
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class ModernMenuCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const ModernMenuCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.gradientColors,
    required this.onTap,
  }) : super(key: key);

  @override
  State<ModernMenuCard> createState() => _ModernMenuCardState();
}

class _ModernMenuCardState extends State<ModernMenuCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: widget.gradientColors[0].withOpacity(0.3),
              blurRadius: _isPressed ? 8 : 12,
              offset: Offset(0, _isPressed ? 2 : 6),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(widget.imagePath, width: 45, height: 45),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 18,
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
