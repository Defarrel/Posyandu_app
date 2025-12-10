import 'dart:async';
import 'package:flutter/material.dart';
import 'package:posyandu_app/core/components/custom_snackbar.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/models/response/balita/balita_response.dart';
import 'package:posyandu_app/data/repository/balita_repository.dart';
import 'package:posyandu_app/presentation/balita/detail_balita_screen.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:intl/intl.dart';
import 'package:posyandu_app/core/components/custom_appbar_cari.dart';

class CariBalitaScreen extends StatefulWidget {
  const CariBalitaScreen({Key? key}) : super(key: key);

  @override
  State<CariBalitaScreen> createState() => _CariBalitaScreenState();
}

class _CariBalitaScreenState extends State<CariBalitaScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BalitaRepository _repository = BalitaRepository();

  List<BalitaResponseModel> _balitaList = [];
  List<BalitaResponseModel> _filteredList = [];

  String _searchQuery = "";
  bool _isLoading = true;
  String _filterKategori = "Semua";

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchBalita();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchBalita() async {
    if (mounted) setState(() => _isLoading = true);

    final Either<String, List<BalitaResponseModel>> result = await _repository
        .getBalita();

    result.fold(
      (error) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(
            message: "Gagal memuat data: $error",
            type: SnackBarType.error,
          ),
        );
      },
      (data) {
        if (!mounted) return;

        data.sort(
          (a, b) =>
              a.namaBalita.toLowerCase().compareTo(b.namaBalita.toLowerCase()),
        );

        setState(() {
          _balitaList = data;

          _filterKategori = "Semua";
          _searchQuery = "";
          _searchController.clear();

          _applyFilter();
          _isLoading = false;
        });
      },
    );
  }

  void _applyFilter() {
    List<BalitaResponseModel> temp = [..._balitaList];

    final query = _searchQuery.toLowerCase();

    if (query.isNotEmpty) {
      temp = temp.where((balita) {
        return balita.namaBalita.toLowerCase().contains(query) ||
            balita.nikBalita.toLowerCase().contains(query);
      }).toList();
    }

    temp = temp.where((balita) {
      final umur = _hitungUmurBulan(balita.tanggalLahir);

      if (_filterKategori == "Balita") return umur >= 12 && umur < 60;
      if (_filterKategori == "Baduta") return umur < 24;

      return true;
    }).toList();

    setState(() => _filteredList = temp);
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() => _searchQuery = value);
      _applyFilter();
    });
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.grey[50],

      appBar: CustomAppBarCari(
        searchController: _searchController,
        filterValue: _filterKategori,
        onSearchChanged: _onSearchChanged,
        onFilterChanged: (value) {
          setState(() => _filterKategori = value!);
          _applyFilter();
        },
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 182),
              child: Column(
                children: [
                  Expanded(
                    child: _filteredList.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: _fetchBalita,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              itemCount: _filteredList.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final balita = _filteredList[index];
                                final umurBulan = _hitungUmurBulan(
                                  balita.tanggalLahir,
                                );

                                return _buildBalitaCard(balita, umurBulan);
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_outlined, size: 64, color: Colors.grey[300]),
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
    );
  }

  Widget _buildBalitaCard(BalitaResponseModel balita, int umurBulan) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailBalitaScreen(balita: balita)),
        );

        _fetchBalita();
      },
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 16),
              _buildBalitaInfo(balita),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
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
        Icons.child_care_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildBalitaInfo(BalitaResponseModel balita) {
    return Expanded(
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
              Icon(Icons.badge_outlined, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  balita.nikBalita,
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
                Icons.person_outline_rounded,
                size: 14,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "Ortu: ${balita.namaOrtu}",
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
        ],
      ),
    );
  }
}
