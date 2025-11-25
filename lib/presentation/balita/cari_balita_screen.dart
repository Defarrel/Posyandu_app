import 'package:flutter/material.dart';
import 'package:posyandu_app/core/components/custom_snackbar.dart';
import 'package:posyandu_app/core/constant/constants.dart';
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
  String _searchQuery = "";
  bool _isLoading = true;
  String _filterKategori = "Semua";

  @override
  void initState() {
    super.initState();
    _fetchBalita();
  }

  Future<void> _fetchBalita() async {
    final Either<String, List<BalitaResponseModel>> result = await _repository
        .getBalita();

    result.fold(
      (error) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(
            message: "Gagal memuat data: $error",
            type: SnackBarType.error,
          ),
        );
      },
      (data) {
        setState(() {
          _balitaList = data;
          _isLoading = false;
        });
      },
    );
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
    var filteredList = _balitaList.where((balita) {
      final query = _searchQuery.toLowerCase();
      return balita.namaBalita.toLowerCase().contains(query) ||
          balita.nikBalita.toLowerCase().contains(query);
    }).toList();

    filteredList = filteredList.where((balita) {
      final umur = _hitungUmurBulan(balita.tanggalLahir);
      if (_filterKategori == "Balita") {
        return umur >= 12 && umur < 60;
      } else if (_filterKategori == "Baduta") {
        return umur < 24;
      }
      return true;
    }).toList();

    filteredList.sort((a, b) => a.namaBalita.compareTo(b.namaBalita));

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: CustomAppBarCari(
        searchController: _searchController,
        filterValue: _filterKategori,
        onSearchChanged: (value) => setState(() => _searchQuery = value),
        onFilterChanged: (value) => setState(() => _filterKategori = value!),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                children: [
                  Expanded(
                    child: filteredList.isEmpty
                        ? const Center(
                            child: Text(
                              "Data balita tidak ditemukan",
                              style: TextStyle(color: Colors.black54),
                            ),
                          )
                        : RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: _fetchBalita,
                            child: ListView.builder(
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final balita = filteredList[index];
                                final umurBulan = _hitungUmurBulan(
                                  balita.tanggalLahir,
                                );

                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          DetailBalitaScreen(balita: balita),
                                    ),
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOut,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "$umurBulan\nBulan",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 14),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                balita.namaBalita,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "NIK: ${balita.nikBalita}",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "Ortu: ${balita.namaOrtu}",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 18,
                                          color: Colors.grey.shade400,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
