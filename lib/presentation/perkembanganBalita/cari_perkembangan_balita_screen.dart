import 'package:flutter/material.dart';
import 'package:posyandu_app/core/constant/constants.dart';
import 'package:posyandu_app/data/models/response/balita/balita_response.dart';
import 'package:posyandu_app/data/repository/balita_repository.dart';
import 'package:posyandu_app/presentation/home/home_root.dart';
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
  int? _expandedIndex;
  bool _isLoading = true;

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal memuat data: $error")));
      },
      (data) {
        setState(() {
          _balitaList = data;
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _balitaList.where((balita) {
      final query = _searchQuery.toLowerCase();
      return balita.namaBalita.toLowerCase().contains(query) ||
          balita.nikBalita.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
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
            size: 18,
          ),
          onPressed: () => HomeRoot.navigateToTab(context, 1),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.menu, color: AppColors.primary),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.primary,
                      ),
                      hintText: "Masukkan Nama atau NIK Balita",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    child: Row(
                      children: const [
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Nama",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            "NIK",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Nama Ortu",
                            style: TextStyle(fontWeight: FontWeight.bold),
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
                                final isExpanded = _expandedIndex == index;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _expandedIndex = isExpanded
                                          ? null
                                          : index;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            balita.namaBalita,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                            overflow: isExpanded
                                                ? TextOverflow.visible
                                                : TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            balita.nikBalita,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                            overflow: isExpanded
                                                ? TextOverflow.visible
                                                : TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            balita.namaOrtu,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                            overflow: isExpanded
                                                ? TextOverflow.visible
                                                : TextOverflow.ellipsis,
                                          ),
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
