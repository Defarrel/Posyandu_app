import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:posyandu_app/core/components/custom_snackbar.dart';
import 'package:posyandu_app/presentation/kelulusan/kelulusan_balita_screen.dart';
import 'package:posyandu_app/presentation/vaksin/vaksin_balita_screen.dart';
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

class LottieWarningDot extends StatelessWidget {
  final String kms;

  const LottieWarningDot({Key? key, required this.kms}) : super(key: key);

  String _getLottiePath() {
    if (kms == "merah") return 'lib/core/assets/lottie/dot_red.json';
    if (kms == "kuning") return 'lib/core/assets/lottie/dot_orange.json';
    return 'lib/core/assets/lottie/dot_green.json';
  }

  Color _getColor() {
    if (kms == "merah") return Colors.redAccent;
    if (kms == "kuning") return const Color.fromARGB(255, 255, 171, 64);
    return const Color.fromARGB(255, 76, 175, 80);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 30,
          height: 30,
          child: Lottie.asset(_getLottiePath(), repeat: true, animate: true),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: _getColor(), shape: BoxShape.circle),
        ),
      ],
    );
  }
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

  List<Map<String, dynamic>> _balitaTrending = [];
  bool _loadingTrending = true;

  String? _bulanDipilih;
  int? _tahunDipilih;
  late List<int> _tahunList;

  String _namaKader = "Memuat...";
  bool _isLoadingChart = true;

  static const double _curvedAppBarHeight = 230.0;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final PerkembanganBalitaRepository _repository =
      PerkembanganBalitaRepository();

  late ScrollController _autoScrollController;
  int _currentAutoIndex = 0;

  int _normal = 0;
  int _kurang = 0;
  int _obesitas = 0;

  @override
  void initState() {
    super.initState();
    _autoScrollController = ScrollController();

    _bulanDipilih = _bulanList[DateTime.now().month - 1];
    _tahunDipilih = DateTime.now().year;
    _tahunList = List.generate(5, (i) => DateTime.now().year - i);

    _refreshAll();
  }

  void _startAutoScroll() {
    if (!mounted || _balitaTrending.isEmpty) return;

    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted || _balitaTrending.isEmpty) return;

      final maxIndex = _balitaTrending.length - 1;

      _currentAutoIndex = (_currentAutoIndex < maxIndex)
          ? _currentAutoIndex + 1
          : 0;

      if (_autoScrollController.hasClients) {
        await _autoScrollController.animateTo(
          _currentAutoIndex * 266.0,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOut,
        );
      }

      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _autoScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadNamaKader() async {
    final nama = await _storage.read(key: 'username');
    if (mounted) {
      setState(() {
        _namaKader = nama ?? "Kader";
      });
    }
  }

  Future<void> _refreshAll() async {
    await _loadNamaKader();
    await _fetchStatistik();
    await _loadBalitaTrending().then((_) {
      if (_balitaTrending.isNotEmpty) {
        _startAutoScroll();
      }
    });
  }

  Future<void> _loadBalitaTrending() async {
    final result = await _repository.getBalitaPerluPerhatian();

    if (mounted) {
      result.fold(
        (err) {
          setState(() {
            _loadingTrending = false;
          });
        },
        (data) {
          setState(() {
            _balitaTrending = data.map((e) => e.toMap()).toList();
            _loadingTrending = false;
          });
        },
      );
    }
  }

  Future<void> _fetchStatistik() async {
    if (mounted) setState(() => _isLoadingChart = true);

    final bulanIndex =
        _bulanList.indexOf(_bulanDipilih ?? _bulanList.first) + 1;
    final tahun = _tahunDipilih ?? DateTime.now().year;

    final result = await _repository.getStatistikPerkembangan(
      bulan: bulanIndex,
      tahun: tahun,
    );

    if (mounted) {
      result.fold(
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar.show(
              message: ("Gagal memuat data grafik: $error"),
              type: SnackBarType.error,
            ),
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
          onRefresh: _refreshAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              top: _curvedAppBarHeight + 10,
              bottom: 20,
            ),
            child: Column(
              children: [
                _buildGrafikCard(),
                const SizedBox(height: 30),
                _buildBalitaTrendingSection(),
                const SizedBox(height: 30),
                _buildMenuSection(context),
                const SizedBox(height: 30),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Grafik Balita Bulan",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary,
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
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
                              setState(() {
                                _tahunDipilih =
                                    int.tryParse(value ?? '') ??
                                    DateTime.now().year;
                              });
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: _isLoadingChart
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : SfCartesianChart(
                          plotAreaBorderWidth: 0,
                          primaryXAxis: CategoryAxis(
                            labelStyle: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          primaryYAxis: NumericAxis(
                            labelStyle: const TextStyle(color: Colors.black),
                            axisLine: const AxisLine(width: 0),
                            majorGridLines: MajorGridLines(
                              color: Colors.black.withOpacity(0.3),
                              width: 0.5,
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
        ),
      ],
    );
  }

  Widget _buildBalitaTrendingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.info_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Informasi Balita",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        if (_loadingTrending)
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          )
        else if (_balitaTrending.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Semua balita dalam kondisi baik bulan ini",
              style: TextStyle(color: Colors.black54),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              controller: _autoScrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: _balitaTrending.length,
              itemBuilder: (context, index) {
                final item = _balitaTrending[index];
                final kms = (item["kms"] ?? "").toString().toLowerCase();

                Color statusColor = kms == "merah"
                    ? Colors.redAccent
                    : kms == "kuning"
                    ? Colors.orangeAccent
                    : Colors.green;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 250,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      LottieWarningDot(kms: kms),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["nama"] ?? "-",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "NIK: ${item["nik"]}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item["alasan"] ?? "-",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.dashboard_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Menu Utama',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
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
                ).then((_) => _refreshAll()),
              ),
              MenuButton(
                title: "Tambah Data\nPerkembangan",
                imagePath: "lib/core/assets/perkembangan.png",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CariPerkembanganBalitaScreen(),
                  ),
                ).then((_) => _refreshAll()),
              ),
              MenuButton(
                title: "Grafik Bulanan\nBalita",
                imagePath: "lib/core/assets/grafik.png",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GrafikBulananScreen(),
                  ),
                ).then((_) => _refreshAll()),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Menu Lainnya',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ModernMenuCard(
            title: "Vaksin Balita",
            subtitle: "Kelola jadwal dan riwayat vaksinasi",
            imagePath: "lib/core/assets/vaksin_balita.png",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VaksinBalitaScreen()),
              ).then((_) => _refreshAll());
            },
          ),
          const SizedBox(height: 16),
          ModernMenuCard(
            title: "Kelulusan Balita",
            subtitle: "Data balita yang telah lulus posyandu",
            imagePath: "lib/core/assets/kelulusan_balita.png",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const KelulusanBalitaScreen(),
                ),
              ).then((_) => _refreshAll());
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
  final VoidCallback onTap;

  const ModernMenuCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: const Offset(0, 3),
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
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        color: Colors.black54.withOpacity(0.9),
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
                  color: AppColors.primary,
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
