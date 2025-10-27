import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
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

  List<PerkembanganBalitaResponseModel> _perkembanganList = [];
  PerkembanganBalitaResponseModel? _filteredPerkembangan;
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
  String _selectedBulan = "";
  int _selectedTahun = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _selectedBulan = _bulanList[DateTime.now().month - 1];
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
        log("Total data dari backend: ${dataList.length}");
        for (var d in dataList) {
          log("Tanggal dari backend: ${d.tanggalPerubahan}");
        }

        setState(() {
          _perkembanganList = dataList;
          _applyFilter();
          _isLoading = false;
        });
      },
    );
  }

  DateTime _safeParseDate(String? raw) {
    if (raw == null || raw.isEmpty) return DateTime(1900);
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return DateTime(1900);
    }
  }

  void _applyFilter() {
    final bulanIndex = _bulanList.indexOf(_selectedBulan) + 1;
    final filtered = _perkembanganList.where((data) {
      final tgl = _safeParseDate(data.tanggalPerubahan);
      return tgl.month == bulanIndex && tgl.year == _selectedTahun;
    }).toList();

    log(
      "[DEBUG] Filter: $_selectedBulan $_selectedTahun -> ditemukan ${filtered.length} data",
    );

    setState(() {
      _filteredPerkembangan = filtered.isNotEmpty ? filtered.last : null;
    });
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
                    _buildRow("Tanggal Lahir", widget.balita.tanggalLahir),
                    _buildRow("NIK Balita", widget.balita.nikBalita),
                    _buildRow("Jenis Kelamin", widget.balita.jenisKelamin),
                    _buildRow("Nama Orang Tua", widget.balita.namaOrtu),
                    _buildRow("NIK Orang Tua", widget.balita.nikOrtu),
                    _buildRow("Nomor Telepon", widget.balita.nomorTelpOrtu),
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
                          onChanged: (val) {
                            setState(() {
                              _selectedBulan = val!;
                              _applyFilter();
                            });
                          },
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          "Tahun:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<int>(
                          value: _selectedTahun,
                          items: List.generate(6, (i) {
                            int year = DateTime.now().year - i;
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }),
                          onChanged: (val) {
                            setState(() {
                              _selectedTahun = val!;
                              _applyFilter();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _filteredPerkembangan == null
                        ? const Text(
                            "Belum ada data perkembangan untuk bulan ini.",
                            style: TextStyle(color: Colors.black54),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildRow(
                                "Berat Badan",
                                "${_filteredPerkembangan?.beratBadan ?? '-'} kg",
                              ),
                              _buildRow(
                                "Tinggi Badan",
                                "${_filteredPerkembangan?.tinggiBadan ?? '-'} cm",
                              ),
                              _buildRow(
                                "Lingkar Lengan",
                                "${_filteredPerkembangan?.lingkarLengan ?? '-'} cm",
                              ),
                              _buildRow(
                                "Lingkar Kepala",
                                "${_filteredPerkembangan?.lingkarKepala ?? '-'} cm",
                              ),
                              _buildRow(
                                "Cara Ukur",
                                _filteredPerkembangan?.caraUkur ?? '-',
                              ),
                              _buildRow(
                                "KMS",
                                _filteredPerkembangan?.kms ?? '-',
                              ),
                              _buildRow(
                                "IMD",
                                _filteredPerkembangan?.imd ?? '-',
                              ),
                              _buildRow(
                                "Vitamin A",
                                _filteredPerkembangan?.vitaminA ?? '-',
                              ),
                              _buildRow(
                                "ASI Eksklusif",
                                _filteredPerkembangan?.asiEks ?? '-',
                              ),
                              _buildRow(
                                "Tanggal Perubahan",
                                DateFormat('d MMMM yyyy', 'id_ID').format(
                                  _safeParseDate(
                                    _filteredPerkembangan?.tanggalPerubahan,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ]),
                  const SizedBox(height: 30),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  // ==== UI Helper ====

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
