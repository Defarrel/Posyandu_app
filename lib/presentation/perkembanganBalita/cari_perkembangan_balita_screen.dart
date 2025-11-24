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

  List<BalitaResponseModel> _balitaList = [];
  String _searchQuery = "";
  String _filterValue = "Semua";
  bool _isLoading = true;
  Map<int, bool> _expandedName = {};

  @override
  void initState() {
    super.initState();
    _fetchBalita();
    Future.delayed(const Duration(milliseconds: 200), () {
      FocusScope.of(context).unfocus();
    });
  }

  Future<void> _fetchBalita() async {
    final Either<String, List<BalitaResponseModel>> result = await _repository
        .getBalita();

    result.fold(
      (error) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(
            message: ("Gagal memuat data: $error"),
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
        title: const Text(
          "Cari Data Perkembangan Balita",
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
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.primary,
                            ),
                            hintText: "Cari Nama / NIK Balita",
                            hintStyle: const TextStyle(color: Colors.black54),
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: _onSearchChanged,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _filterValue,
                              icon: const Icon(
                                Icons.filter_list,
                                color: AppColors.primary,
                              ),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: "Semua",
                                  child: Text("Semua"),
                                ),
                                DropdownMenuItem(
                                  value: "Balita",
                                  child: Text("Balita"),
                                ),
                                DropdownMenuItem(
                                  value: "Baduta",
                                  child: Text("Baduta"),
                                ),
                              ],
                              onChanged: _onFilterChanged,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Nama",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            "NIK",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Aksi",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: filteredList.isEmpty
                        ? const Center(
                            child: Text(
                              "Data balita tidak ditemukan",
                              style: TextStyle(color: Colors.black),
                            ),
                          )
                        : RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: _fetchBalita,
                            child: ListView.builder(
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final balita = filteredList[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _expandedName[index] =
                                                  !(_expandedName[index] ??
                                                      false);
                                            });
                                          },
                                          child: AnimatedSize(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            child: Text(
                                              balita.namaBalita,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black,
                                              ),
                                              maxLines:
                                                  _expandedName[index] == true
                                                  ? 2
                                                  : 1,
                                              overflow:
                                                  _expandedName[index] == true
                                                  ? TextOverflow.visible
                                                  : TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          balita.nikBalita,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: GestureDetector(
                                            onTap: () async {
                                              final now = DateTime.now();
                                              final result =
                                                  await PerkembanganBalitaRepository()
                                                      .cekPerkembanganBulanIni(
                                                        nikBalita:
                                                            balita.nikBalita,
                                                      );
                                              result.fold(
                                                (error) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    CustomSnackBar.show(
                                                      message: (error),
                                                      type: SnackBarType.error,
                                                    ),
                                                  );
                                                },
                                                (sudahAda) {
                                                  if (sudahAda) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) => Dialog(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                18,
                                                              ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                20,
                                                              ),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              const Text(
                                                                "Perhatian !",
                                                                style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors.red,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              const Text(
                                                                "Data perkembangan bulan ini sudah ditambahkan.\n"
                                                                "Apakah Anda yakin ingin menambah data baru?",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                              ),
                                                              const SizedBox(
                                                                height: 20,
                                                              ),

                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    child: ElevatedButton(
                                                                      style: ElevatedButton.styleFrom(
                                                                        backgroundColor:
                                                                            Colors.red,
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      onPressed: () =>
                                                                          Navigator.pop(
                                                                            context,
                                                                          ),
                                                                      child: const Text(
                                                                        "Batal",
                                                                        style: TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Expanded(
                                                                    child: ElevatedButton(
                                                                      style: ElevatedButton.styleFrom(
                                                                        backgroundColor:
                                                                            AppColors.primary,
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      onPressed: () {
                                                                        Navigator.pop(
                                                                          context,
                                                                        ); 
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
                                                                        style: TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                        ),
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
                                                  } else {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            TambahPerkembanganBalita(
                                                              nikBalita: balita
                                                                  .nikBalita,
                                                              namaBalita: balita
                                                                  .namaBalita,
                                                            ),
                                                      ),
                                                    );
                                                  }
                                                },
                                              );
                                            },

                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                    horizontal: 13,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF5AC05E),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: const Text(
                                                "Perkembangan",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
