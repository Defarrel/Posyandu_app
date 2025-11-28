import 'package:flutter/material.dart';
import 'package:posyandu_app/core/components/custom_snackbar.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/models/response/balita/balita_response.dart';
import 'package:posyandu_app/data/repository/balita_repository.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:posyandu_app/presentation/vaksin/vaksin_detail_screen.dart';
import 'package:posyandu_app/presentation/vaksin/crud_vaksin/kelola_vaksin_screen.dart';
import 'package:intl/intl.dart';

class VaksinBalitaScreen extends StatefulWidget {
  const VaksinBalitaScreen({super.key});

  @override
  State<VaksinBalitaScreen> createState() => _VaksinBalitaScreenState();
}

class _VaksinBalitaScreenState extends State<VaksinBalitaScreen> {
  final BalitaRepository _balitaRepo = BalitaRepository();
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  List<BalitaResponseModel> _list = [];
  String _search = "";
  bool _loading = true;
  bool _showAllBalita = false;
  int _currentPage = 0;

  final GlobalKey _balitaSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fetchBalita();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchBalita() async {
    setState(() => _loading = true);

    final Either<String, List<BalitaResponseModel>> result = await _balitaRepo
        .getBalita();

    result.fold(
      (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(
            message: ("Gagal memuat data: $err"),
            type: SnackBarType.error,
          ),
        );
        setState(() => _loading = false);
      },
      (data) {
        setState(() {
          _list = data;
          _loading = false;
        });
      },
    );
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_pageController.hasClients && mounted) {
        if (_currentPage < 2) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
  }

  void _scrollToBalitaSection() {
    final context = _balitaSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  int _hitungUmurBulan(String tanggalLahir) {
    try {
      final lahir = DateFormat("yyyy-MM-dd").parse(tanggalLahir);
      final now = DateTime.now();
      return (now.difference(lahir).inDays / 30.4375).floor();
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _list.where((b) {
      return b.namaBalita.toLowerCase().contains(_search.toLowerCase()) ||
          b.nikBalita.contains(_search);
    }).toList();

    final displayedBalita = _showAllBalita
        ? filtered
        : filtered.take(5).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Vaksin Balita",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Cari nama / NIK balita",
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.primary,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() => _search = value);

                  if (value.isNotEmpty) {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      _scrollToBalitaSection();
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 20),

            _buildBalitaSection(displayedBalita, filtered.length),
          ],
        ),
      ),
    );
  }

  Widget _buildBalitaSection(
    List<BalitaResponseModel> displayedBalita,
    int totalBalita,
  ) {
    return Expanded(
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(child: _buildVaksinasiSection()),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          if (_showAllBalita)
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyHeaderDelegate(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Data Balita",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showAllBalita = false;
                          });
                        },
                        child: const Text(
                          "Lihat Lebih Sedikit",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Container(
                key: _balitaSectionKey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Data Balita",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (totalBalita > 5)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showAllBalita = true;
                          });
                        },
                        child: Text(
                          "Lihat Semua ($totalBalita)",
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          if (_loading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            )
          else if (displayedBalita.isEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.child_care, size: 60, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      "Data balita tidak ditemukan",
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final b = displayedBalita[index];
                final umur = _hitungUmurBulan(b.tanggalLahir);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    elevation: 2,
                    shadowColor: Colors.black.withOpacity(0.1),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VaksinDetailScreen(balita: b),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withOpacity(0.9),
                                    AppColors.primary.withOpacity(0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.child_care,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          b.namaBalita,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 16,
                                        color: Colors.grey.shade500,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  Row(
                                    children: [
                                      Icon(
                                        Icons.badge_outlined,
                                        size: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          "NIK: ${_formatNIK(b.nikBalita)}",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),

                                  Row(
                                    children: [
                                      Icon(
                                        Icons.cake_outlined,
                                        size: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "$umur bulan",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }, childCount: displayedBalita.length),
            ),

          if (!_showAllBalita && totalBalita > 5)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "...",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatNIK(String nik) {
    if (nik.length <= 12) return nik;

    final chunks = <String>[];
    for (int i = 0; i < nik.length; i += 4) {
      final end = i + 4;
      chunks.add(nik.substring(i, end < nik.length ? end : nik.length));
    }
    return chunks.join(' ');
  }

  Widget _buildVaksinasiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Vaksinasi Balita",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 180,
          child: PageView(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              _buildVaksinCard(
                icon: Icons.vaccines,
                title: "Kelola Vaksin",
                subtitle: "Tambah, edit, dan kelola data vaksin",
                buttonText: "Kelola Sekarang",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const KelolaVaksinScreen(),
                    ),
                  );
                },
              ),

              _buildVaksinCard(
                icon: Icons.medical_services,
                title: "Vaksin Balita Sekarang",
                subtitle: "Pilih balita untuk divaksin sekarang",
                buttonText: "Pilih Balita",
                onTap: () {
                  _scrollToBalitaSection();
                  ScaffoldMessenger.of(context).showSnackBar(
                    CustomSnackBar.show(
                      message: "Pilih balita untuk divaksin sekarang",
                      type: SnackBarType.info,
                    ),
                  );
                },
              ),

              _buildVaksinCard(
                icon: Icons.calendar_today,
                title: "Jadwal Vaksin",
                subtitle: "Lihat jadwal vaksin hari ini",
                buttonText: "Lihat Jadwal",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    CustomSnackBar.show(
                      message: "Fitur Belum Tersedia",
                      type: SnackBarType.info,
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 3; i++)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == i
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.3),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildVaksinCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          if (shrinkOffset > 0)
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: child,
    );
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
