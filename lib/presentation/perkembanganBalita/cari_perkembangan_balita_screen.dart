import 'package:flutter/material.dart';
import 'package:posyandu_app/core/components/custom_snackbar.dart';
import 'package:posyandu_app/core/constant/constants.dart';
import 'package:posyandu_app/data/models/response/balita/balita_response.dart';
import 'package:posyandu_app/data/repository/balita_repository.dart';
import 'package:posyandu_app/data/repository/perkembangan_balita_repository.dart';
import 'package:posyandu_app/presentation/perkembanganBalita/tambah_perkembangan_balita.dart';
import 'package:dartz/dartz.dart' hide State;

class CariPerkembanganBalitaScreen extends StatefulWidget {
  const CariPerkembanganBalitaScreen({Key? key}) : super(key: key);

  @override
  State<CariPerkembanganBalitaScreen> createState() =>
      _CariPerkembanganBalitaScreenState();
}

class _CariPerkembanganBalitaScreenState
    extends State<CariPerkembanganBalitaScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BalitaRepository _repository = BalitaRepository();
  final ScrollController _scrollController =
      ScrollController(); 

  List<BalitaResponseModel> _balitaList = [];
  String _searchQuery = "";
  String _filterValue = "Semua";
  bool _isLoading = true;
  bool _isStickyVisible = false; 
  @override
  void initState() {
    super.initState();
    _fetchBalita();

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > 80 && !_isStickyVisible) {
      setState(() => _isStickyVisible = true);
    } else if (_scrollController.offset <= 80 && _isStickyVisible) {
      setState(() => _isStickyVisible = false);
    }
  }

  Future<void> _fetchBalita() async {
    final Either<String, List<BalitaResponseModel>> result = await _repository
        .getBalita();

    result.fold(
      (error) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar.show(
              message: ("Gagal memuat data: $error"),
              type: SnackBarType.error,
            ),
          );
        }
      },
      (data) {
        if (mounted) {
          setState(() {
            _balitaList = data;
            _isLoading = false;
          });
        }
      },
    );
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
  }

  void _onFilterChanged(String? value) {
    setState(() => _filterValue = value ?? "Semua");
  }

  int _hitungUmurBulan(String tanggalLahir) {
    try {
      final birthDate = DateTime.parse(tanggalLahir);
      final now = DateTime.now();
      return (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    } catch (_) {
      return 0;
    }
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

  @override
  Widget build(BuildContext context) {
    final filteredList = _balitaList.where((balita) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          balita.namaBalita.toLowerCase().contains(query) ||
          balita.nikBalita.toLowerCase().contains(query);

      final umurBulan = _hitungUmurBulan(balita.tanggalLahir);

      bool matchesFilter = true;
      if (_filterValue == "Balita") {
        matchesFilter = umurBulan >= 24 && umurBulan <= 59;
      } else if (_filterValue == "Baduta") {
        matchesFilter = umurBulan < 24;
      }

      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Cari Data Balita",
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
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Stack(
              children: [
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        color: Colors.white, 
                        child: Column(
                          children: [
                            _buildSearchFilterRow(isSticky: false),

                            const SizedBox(height: 12),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Tekan tombol (+) pada kartu untuk input data.",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary.withOpacity(
                                          0.8,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    filteredList.isEmpty
                        ? SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_search_outlined,
                                    size: 64,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Data balita tidak ditemukan",
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final balita = filteredList[index];
                                final umurBulan = _hitungUmurBulan(
                                  balita.tanggalLahir,
                                );

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildBalitaCard(balita, umurBulan),
                                );
                              }, childCount: filteredList.length),
                            ),
                          ),
                  ],
                ),

                AnimatedSlide(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  offset: _isStickyVisible
                      ? const Offset(0, 0)
                      : const Offset(0, -1.0),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isStickyVisible ? 1.0 : 0.0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: _buildSearchFilterRow(isSticky: true),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchFilterRow({required bool isSticky}) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: isSticky ? Colors.grey[100] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSticky
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
              border: isSticky ? null : Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.primary,
                  size: 22,
                ),
                hintText: "Cari Nama / NIK Balita",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isSticky ? Colors.grey[100] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSticky
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
              border: isSticky ? null : Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _filterValue,
                isExpanded: true,
                icon: Icon(
                  Icons.filter_list,
                  color: isSticky ? AppColors.primary : AppColors.primary,
                  size: 20,
                ),
                style: TextStyle(
                  color: isSticky ? Colors.white : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                dropdownColor: Colors.white,
                items: const [
                  DropdownMenuItem(
                    value: "Semua",
                    child: Text(
                      "Semua",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                  DropdownMenuItem(
                    value: "Balita",
                    child: Text(
                      "Balita",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                  DropdownMenuItem(
                    value: "Baduta",
                    child: Text(
                      "Baduta",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
                onChanged: _onFilterChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalitaCard(BalitaResponseModel balita, int umurBulan) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
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
                  Icons.show_chart_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      balita.namaBalita,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatNIK(balita.nikBalita),
                            style: TextStyle(
                              fontSize: 12,
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
                        const SizedBox(width: 4),
                        Text(
                          "$umurBulan Bulan",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    final result = await PerkembanganBalitaRepository()
                        .cekPerkembanganBulanIni(nikBalita: balita.nikBalita);

                    result.fold(
                      (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          CustomSnackBar.show(
                            message: error,
                            type: SnackBarType.error,
                          ),
                        );
                      },
                      (sudahAda) {
                        if (sudahAda) {
                          _showKonfirmasiDialog(balita);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TambahPerkembanganBalita(
                                nikBalita: balita.nikBalita,
                                namaBalita: balita.namaBalita,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.primary,
                      size: 24,
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

  void _showKonfirmasiDialog(BalitaResponseModel balita) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Data Sudah Ada",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Data perkembangan bulan ini sudah ditambahkan. Apakah Anda yakin ingin menambah data baru lagi?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TambahPerkembanganBalita(
                              nikBalita: balita.nikBalita,
                              namaBalita: balita.namaBalita,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "Tambah",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
