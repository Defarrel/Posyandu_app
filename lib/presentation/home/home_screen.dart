import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:posyandu_app/core/components/buttons.dart';
import 'package:posyandu_app/core/components/custom_dropdown_button.dart';
import 'package:posyandu_app/core/components/custom_appbar_home.dart';
import 'package:posyandu_app/presentation/home/home_root.dart';

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
  String _namaKader = "Memuat...";

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadNamaKader();
  }

  Future<void> _loadNamaKader() async {
    final nama = await _storage.read(key: 'username');
    setState(() {
      _namaKader = nama ?? "Kader";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFEFF7FF),
      appBar: CustomAppBarHome(
        nama: _namaKader, // ← tampil nama kader login
        posyandu: "Posyandu Dahlia", 
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              const SizedBox(height: 240),
              _buildGrafikCard(),
              const SizedBox(height: 20),
              _buildMenuSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrafikCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0098F8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Grafik Balita Bulan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                CustomDropdownButton(
                  value: _bulanDipilih ?? _bulanList.first,
                  items: _bulanList,
                  isCompact: true,
                  textColor: Colors.white,
                  onChanged: (value) {
                    setState(() => _bulanDipilih = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  _bulanDipilih == null
                      ? 'Silakan pilih bulan untuk menampilkan grafik'
                      : 'Grafik bulan $_bulanDipilih akan ditampilkan di sini',
                  style: const TextStyle(color: Colors.grey),
                ),
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
                onTap: () => HomeRoot.navigateToTab(context, 0),
              ),
              MenuButton(
                title: "Tambah Data\nPerkembangan",
                imagePath: "lib/core/assets/perkembangan.png",
                onTap: () {},
              ),
              MenuButton(
                title: "Grafik Bulanan\nBalita",
                imagePath: "lib/core/assets/grafik.png",
                onTap: () {},
              ),
              MenuButton(
                title: "Cari Data\nBalita",
                imagePath: "lib/core/assets/caridata.png",
                onTap: () => HomeRoot.navigateToTab(context, 2),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
