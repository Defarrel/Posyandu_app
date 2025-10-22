import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../../core/components/buttons.dart';
import '../../core/components/custom_dropdown_button.dart';
import '../../core/components/custom_navbar_bot.dart';
import '../home/tambah_balita.dart';
=======
import 'package:posyandu_app/core/components/button.dart';
import 'package:posyandu_app/core/components/custom_dropdown_button.dart';
import 'package:posyandu_app/core/components/custom_appbar_home.dart';
import 'package:posyandu_app/presentation/home/home_root.dart';
>>>>>>> 524c3a52ff6372901ea53b1f98968b6984643fe1

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
<<<<<<< HEAD
  int _currentIndex = 1;

  void _onNavbarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
=======
>>>>>>> 524c3a52ff6372901ea53b1f98968b6984643fe1

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // ✅ Biar appbar meluber ke atas tanpa putih
      backgroundColor: const Color(0xFFEFF7FF),
      appBar: const CustomAppBarHome(
        nama: "Kader 02",
        posyandu: "Posyandu Dahlia X RT 2",
      ),
      body: SafeArea(
        top: false, // ✅ Biar area atas tidak jadi putih
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              const SizedBox(height: 240), // ✅ Jarak dari AppBar melengkung
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
<<<<<<< HEAD
            Center(child: Text("Halaman Tambah Balita Baru")),

            // ======== HALAMAN HOME ========
            Column(
              children: [
                // ======== HEADER ========
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0098F8),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: 20,
                  ),
                  child: Column(
                    children: [
                      // ======== HAMBURGER & LOGOUT ========
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Menu ditekan"),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Logout ditekan"),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      // ======== PROFIL PENGGUNA ========
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage(
                              'lib/core/assets/profile.jpg',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Halo,',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Kader 02',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Posyandu Dahlia RW 11',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ======== KARTU GRAFIK ========
                Padding(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ======== TITLE + DROPDOWN ========
                        Row(
                          children: [
                            const Text(
                              'Grafik Balita Bulan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 7),
                            CustomDropdownButton(
                              value: _bulanDipilih ?? _bulanList.first,
                              items: _bulanList,
                              isCompact: true,
                              textColor: Colors.white,
                              onChanged: (value) {
                                setState(() {
                                  _bulanDipilih = value!;
                                });
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // ======== GRAFIK (placeholder) ========
                        Container(
                          height: 100,
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
                ),

                const SizedBox(height: 20),

                // ======== MENU ========
=======
            Row(
              children: [
>>>>>>> 524c3a52ff6372901ea53b1f98968b6984643fe1
                const Text(
                  'Grafik Balita Bulan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
<<<<<<< HEAD
                const SizedBox(height: 16),

                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: [
                        MenuButton(
                          title: "Tambah Balita\nBaru",
                          imagePath: "lib/core/assets/tambahbalita.png",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TambahDataBalitaPage(),
                              ),
                            );
                          },
                        ),
                        MenuButton(
                          title: "Tambah Data\nPerkembangan",
                          imagePath: "lib/core/assets/perkembangan.png",
                          onTap: () {
                            print("Tambah Data Perkembangan diklik");
                          },
                        ),
                        MenuButton(
                          title: "Grafik Bulanan\nBalita",
                          imagePath: "lib/core/assets/grafik.png",
                          onTap: () {
                            print("Grafik Bulanan Balita diklik");
                          },
                        ),
                        MenuButton(
                          title: "Cari Data\nBalita",
                          imagePath: "lib/core/assets/caridata.png",
                          onTap: () {
                            print("Cari Data Balita diklik");
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Center(child: Text("Halaman Data Balita")),
=======
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
>>>>>>> 524c3a52ff6372901ea53b1f98968b6984643fe1
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
