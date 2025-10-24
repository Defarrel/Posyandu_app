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

  final List<String> _bulanList = const [
    "Januari",
    "Februari",
    "Maret",
    "April",
    "Mei",
    "Juni",
    "Juli",
    "Agustus",
    "September",
    "Oktober",
    "November",
    "Desember",
  ];
  String _selectedBulan = "November";

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
          if (dataList.isNotEmpty) _latestPerkembangan = dataList.last;
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Detail Data Balita",
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Biodata Balita"),
                  _buildContentCard([
                    _buildRow("Nama Balita", widget.balita.namaBalita),
                    _buildRow(
                      "TTL (Tempat, Tanggal Lahir)",
                      widget.balita.tanggalLahir,
                    ),
                    _buildRow("NIK Balita", widget.balita.nikBalita),
                    _buildRow("Jenis Kelamin", widget.balita.jenisKelamin),
                    _buildRow("Nama Ortu", widget.balita.namaOrtu),
                    _buildRow("NIK Ortu", widget.balita.nikOrtu),
                    _buildRow("No Telp", widget.balita.nomorTelpOrtu),
                    _buildRow("Alamat", widget.balita.alamat),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Data Perkembangan Balita"),
                  _buildContentCard([
                    Row(
                      children: [
                        const Text(
                          "Bulan:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _selectedBulan,
                          items: _bulanList
                              .map(
                                (b) =>
                                    DropdownMenuItem(value: b, child: Text(b)),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedBulan = val!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _latestPerkembangan == null
                        ? const Text(
                            "Belum ada data perkembangan.",
                            style: TextStyle(color: Colors.black54),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                            ],
                          ),
                  ]),
                  const SizedBox(height: 30),
                  _buildActionButtons(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  // Judul Biru di Atas Card
  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  // Konten Card (Abu + Shadow)
  Widget _buildContentCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 5,
            offset: const Offset(0, 3),
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

  Widget _buildActionButtons() {
    return Row(
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
              backgroundColor: Colors.blue,
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
    );
  }
}
