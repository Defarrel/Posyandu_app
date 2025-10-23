import 'package:flutter/material.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/models/response/balita/balita_response.dart';
import 'package:posyandu_app/data/models/response/perkembangan_balita/perkembangan_balita_reponse.dart';
import 'package:posyandu_app/data/repository/perkembangan_balita_repository.dart';
import 'package:dartz/dartz.dart' hide State;

class DetailBalitaScreen extends StatefulWidget {
  final BalitaResponseModel balita;

  const DetailBalitaScreen({super.key, required this.balita});

  @override
  State<DetailBalitaScreen> createState() => _DetailBalitaScreenState();
}

class _DetailBalitaScreenState extends State<DetailBalitaScreen> {
  final PerkembanganBalitaRepository _repository =
      PerkembanganBalitaRepository();
  PerkembanganBalitaResponseModel? _latestPerkembangan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPerkembangan();
  }

  Future<void> _fetchPerkembangan() async {
    final Either<String, List<PerkembanganBalitaResponseModel>> result =
        await _repository.getPerkembanganByNIK(widget.balita.nikBalita);

    result.fold(
      (error) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal memuat: $error")));
      },
      (dataList) {
        setState(() {
          // Ambil data terbaru (misal urutan terakhir)
          if (dataList.isNotEmpty) {
            _latestPerkembangan = dataList.last;
          }
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF9F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detail Data Balita",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Biodata Balita ---
                  const Text(
                    "Biodata Balita",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildCard([
                    _buildRow("Nama Balita", widget.balita.namaBalita),
                    _buildRow("TTL", widget.balita.tanggalLahir),
                    _buildRow("NIK Balita", widget.balita.nikBalita),
                    _buildRow("Jenis Kelamin", widget.balita.jenisKelamin),
                    _buildRow("Nama Ortu", widget.balita.namaOrtu),
                    _buildRow("NIK Ortu", widget.balita.nikOrtu),
                    _buildRow("No Telp", widget.balita.nomorTelpOrtu),
                    _buildRow("Alamat", widget.balita.alamat),
                  ]),

                  const SizedBox(height: 16),

                  // --- Data Perkembangan ---
                  const Text(
                    "Data Perkembangan Balita",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),

                  _latestPerkembangan == null
                      ? _buildCard([
                          const Text(
                            "Belum ada data perkembangan.",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ])
                      : _buildCard([
                          _buildRow(
                            "Bulan",
                            _latestPerkembangan?.tanggalPerubahan ?? "-",
                          ),
                          _buildRow(
                            "Berat Badan",
                            "${_latestPerkembangan?.beratBadan ?? '-'} kg",
                          ),
                          _buildRow(
                            "Tinggi Badan",
                            "${_latestPerkembangan?.tinggiBadan ?? '-'} cm",
                          ),
                          _buildRow(
                            "Lingkar Lengan",
                            "${_latestPerkembangan?.lingkarLengan ?? '-'} cm",
                          ),
                          _buildRow(
                            "Lingkar Kepala",
                            "${_latestPerkembangan?.lingkarKepala ?? '-'} cm",
                          ),
                          _buildRow(
                            "Cara Ukur",
                            _latestPerkembangan?.caraUkur ?? '-',
                          ),
                          _buildRow("KMS", _latestPerkembangan?.kms ?? '-'),
                          _buildRow("IMD", _latestPerkembangan?.imd ?? '-'),
                          _buildRow(
                            "Vitamin A",
                            _latestPerkembangan?.vitaminA ?? '-',
                          ),
                          _buildRow(
                            "ASI Eksklusif",
                            _latestPerkembangan?.asiEks ?? '-',
                          ),
                        ]),

                  const SizedBox(height: 20),

                  // Tombol Aksi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text("Perbarui Data"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text("Cetak Kartu"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text("Hapus Data"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: "$title: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
