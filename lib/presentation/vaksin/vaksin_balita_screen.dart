import 'package:flutter/material.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/models/response/balita/balita_response.dart';
import 'package:posyandu_app/data/repository/balita_repository.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:posyandu_app/presentation/vaksin/vaksin_detail_screen.dart';

class VaksinBalitaScreen extends StatefulWidget {
  const VaksinBalitaScreen({super.key});

  @override
  State<VaksinBalitaScreen> createState() => _VaksinBalitaScreenState();
}

class _VaksinBalitaScreenState extends State<VaksinBalitaScreen> {
  final BalitaRepository _balitaRepo = BalitaRepository();
  final TextEditingController _searchController = TextEditingController();

  List<BalitaResponseModel> _list = [];
  String _search = "";
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchBalita();
  }

  Future<void> _fetchBalita() async {
    setState(() => _loading = true);

    final Either<String, List<BalitaResponseModel>> result = await _balitaRepo
        .getBalita();

    result.fold(
      (err) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal memuat data: $err")));
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

  @override
  Widget build(BuildContext context) {
    final filtered = _list.where((b) {
      return b.namaBalita.toLowerCase().contains(_search.toLowerCase()) ||
          b.nikBalita.contains(_search);
    }).toList();

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
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari nama atau NIK balita...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
            const SizedBox(height: 20),

            // Content
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : filtered.isEmpty
                  ? const Center(
                      child: Text(
                        "Data balita tidak ditemukan",
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final b = filtered[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VaksinDetailScreen(),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: AppColors.primary
                                      .withOpacity(0.2),
                                  child: const Icon(
                                    Icons.child_care,
                                    size: 28,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 14),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        b.namaBalita,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        b.nikBalita,
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 18,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
