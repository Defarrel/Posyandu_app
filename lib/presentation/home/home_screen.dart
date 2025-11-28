import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:posyandu_app/core/components/custom_snackbar.dart';
import 'package:posyandu_app/presentation/balita/detail_balita_screen.dart';
import 'package:posyandu_app/presentation/kelulusan/kelulusan_balita_screen.dart';
import 'package:posyandu_app/presentation/vaksin/vaksin_balita_screen.dart';
import 'package:posyandu_app/services/services_http_client.dart';
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
import 'package:posyandu_app/data/models/response/balita/balita_response.dart';

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

  static const double _curvedAppBarHeight = 200;
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
    _refreshAll();
  }

  Future<void> _refreshAll() async {
    await _loadNamaKader();
    await _fetchStatistik();
    await _loadBalitaTrending();
  }

  Future<void> _loadNamaKader() async {
    final nama = await _storage.read(key: 'username');
    if (mounted) {
      setState(() {
        _namaKader = nama ?? "Kader";
      });
    }
  }

  Future<void> _loadBalitaTrending() async {
    final result = await _repository.getBalitaPerluPerhatian();
    if (mounted) {
      result.fold(
        (err) => setState(() => _loadingTrending = false),
        (data) => setState(() {
          _balitaTrending = data.map((e) => e.toMap()).toList();
          _loadingTrending = false;
        }),
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

    if (!mounted) return;
    result.fold(
      (error) async {
        if (error.toString().toLowerCase().contains("token")) {
          final client = ServiceHttpClient();
          await client.handleTokenExpiredFromOutside();
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(
            message: "Gagal: $error",
            type: SnackBarType.error,
          ),
        );
        if (mounted) setState(() => _isLoadingChart = false);
      },
      (data) {
        if (mounted) {
          setState(() {
            _normal = data["normal"];
            _kurang = data["kurang"];
            _obesitas = data["obesitas"];
            _isLoadingChart = false;
          });
        }
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

                BalitaTrendingSlider(
                  data: _balitaTrending,
                  isLoading: _loadingTrending,
                ),

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

class BalitaTrendingSlider extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final bool isLoading;

  const BalitaTrendingSlider({
    super.key,
    required this.data,
    required this.isLoading,
  });

  @override
  State<BalitaTrendingSlider> createState() => _BalitaTrendingSliderState();
}

class _BalitaTrendingSliderState extends State<BalitaTrendingSlider> {
  late ScrollController _scrollController;
  Timer? _timer;
  int _currentIndex = 0;
  bool _isUserTouching = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_isUserTouching &&
          widget.data.isNotEmpty &&
          _scrollController.hasClients) {
        if (_currentIndex < widget.data.length - 1) {
          _currentIndex++;
        } else {
          _currentIndex = 0;
        }

        _scrollController.animateTo(
          _currentIndex * 266.0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _confirmAndNavigate(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary),
              const SizedBox(width: 10),
              const Text("Lihat Detail?"),
            ],
          ),
          content: Text.rich(
            TextSpan(
              text: "Apakah anda ingin melihat data lengkap \n",
              style: const TextStyle(color: Colors.black87),
              children: [
                TextSpan(
                  text: item['nama'] ?? "-",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const TextSpan(text: " ?"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: AppColors.primary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);

                try {
                  final safeMap = {
                    'nik_balita': item['nik']?.toString() ?? '',
                    'nama_balita': item['nama']?.toString() ?? '',
                    'jenis_kelamin': '',
                    'tanggal_lahir': '1900-01-01',
                    'anak_ke_berapa': '0',
                    'nomor_kk': '',
                    'nama_ortu': '',
                    'nik_ortu': '',
                    'nomor_telp_ortu': '',
                    'alamat': '',
                    'rt': '',
                    'rw': '',
                    'createdAt': '',
                    ...item,
                    'nik_balita': item['nik']?.toString() ?? '',
                    'nama_balita':
                        item['nama']?.toString() ??
                        item['nama_balita']?.toString() ??
                        '',
                  };

                  final balitaModel = BalitaResponseModel.fromMap(safeMap);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailBalitaScreen(balita: balitaModel),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    CustomSnackBar.show(
                      message:
                          "Gagal memuat detail balita. Error konversi: Data di daftar trending tidak lengkap.",
                      type: SnackBarType.error,
                    ),
                  );
                }
              },
              child: const Text(
                "Ya, Lihat",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        if (widget.isLoading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          )
        else if (widget.data.isEmpty)
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
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification) {
                  setState(() => _isUserTouching = true);
                } else if (notification is ScrollEndNotification) {
                  setState(() => _isUserTouching = false);
                }
                return false;
              },
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                itemCount: widget.data.length,
                itemBuilder: (context, index) {
                  return _buildModernCard(context, widget.data[index]);
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildModernCard(BuildContext context, Map<String, dynamic> item) {
    final kms = (item["kms"] ?? "").toString().toLowerCase();
    Color statusColor;
    Color statusBgColor;

    if (kms == "merah") {
      statusColor = Colors.red;
      statusBgColor = Colors.red.withOpacity(0.1);
    } else if (kms == "kuning") {
      statusColor = Colors.orange;
      statusBgColor = Colors.orange.withOpacity(0.1);
    } else {
      statusColor = Colors.green;
      statusBgColor = Colors.green.withOpacity(0.1);
    }

    return GestureDetector(
      onTap: () => _confirmAndNavigate(context, item),
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 6, color: statusColor),
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Container(
                      width: 30,
                      height: 50,
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: Center(child: LottieWarningDot(kms: kms)),
                    ),
                    const SizedBox(width: 14),
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
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "NIK: ${item["nik"]}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item["alasan"] ?? "-",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
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
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE0E0E0).withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.03),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(80),
                      topRight: Radius.circular(24),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryLight.withOpacity(0.1),
                            AppColors.primary.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Image.asset(
                          widget.imagePath,
                          width: 45,
                          height: 45,
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
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
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              color: Colors.black54.withOpacity(0.6),
                              fontSize: 13,
                              height: 1.3,
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
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
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
