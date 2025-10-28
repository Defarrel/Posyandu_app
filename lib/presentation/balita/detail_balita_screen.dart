import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/models/request/perkembangan_balita/perkembangan_request_model.dart';
import 'package:posyandu_app/data/models/response/balita/balita_response.dart';
import 'package:posyandu_app/data/models/response/perkembangan_balita/perkembangan_balita_reponse.dart';
import 'package:posyandu_app/data/repository/perkembangan_balita_repository.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:posyandu_app/presentation/perkembanganBalita/tambah_perkembangan_balita.dart';

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
  Color _warnaNama = Colors.black;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _selectedBulan = _bulanList[DateTime.now().month - 1];
    _fetchPerkembangan();
  }

  Future<void> _fetchPerkembangan() async {
    final result = await _repository.getPerkembanganByNIK(
      widget.balita.nikBalita,
    );

    result.fold(
      (error) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal memuat: $error")));
      },
      (dataList) {
        setState(() {
          _perkembanganList = dataList;
          _applyFilter();

          if (_perkembanganList.isNotEmpty) {
            final lastKMS = _perkembanganList.last.kms?.toLowerCase() ?? "";
            if (lastKMS == "merah") {
              _warnaNama = Colors.red;
            } else if (lastKMS == "hijau") {
              _warnaNama = Colors.green;
            } else {
              _warnaNama = Colors.black;
            }
          }

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

  String _formatTanggalIndonesia(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "-";
    try {
      final date = DateTime.parse(rawDate);
      return DateFormat("d MMMM yyyy", "id_ID").format(date);
    } catch (e) {
      return rawDate; // fallback jika format salah
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

  Future<void> _handleDelete() async {
    if (_filteredPerkembangan == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: const Text(
          "Apakah kamu yakin ingin menghapus data perkembangan ini?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _repository.deletePerkembangan(
        _filteredPerkembangan!.id,
      );
      result.fold(
        (error) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error))),
        (success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(success)));
          _fetchPerkembangan();
        },
      );
    }
  }

  Future<void> _handleUpdate() async {
    if (_filteredPerkembangan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tidak ada data perkembangan untuk diperbarui."),
        ),
      );
      return;
    }

    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TambahPerkembanganBalita(
          nikBalita: widget.balita.nikBalita,
          namaBalita: widget.balita.namaBalita,
          existingData: _filteredPerkembangan,
        ),
      ),
    );

    if (updated == true) {
      _fetchPerkembangan();
    }
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
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: RichText(
                        text: TextSpan(
                          text: "Nama Balita: ",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: widget.balita.namaBalita,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _warnaNama,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildRow(
                      "Tanggal Lahir",
                      _formatTanggalIndonesia(widget.balita.tanggalLahir),
                    ),

                    _buildRow("NIK Balita", widget.balita.nikBalita),
                    _buildRow("Jenis Kelamin", widget.balita.jenisKelamin),
                    _buildRow("Nama Orang Tua", widget.balita.namaOrtu),
                    _buildRow("Alamat", widget.balita.alamat),
                  ]),
                  const SizedBox(height: 20),

                  _buildSectionTitle("Data Perkembangan Balita"),
                  _buildContentCard([
                    _buildFilterDropdown(),
                    const SizedBox(height: 8),
                    _filteredPerkembangan == null
                        ? const Text(
                            "Belum ada data perkembangan untuk bulan ini.",
                            style: TextStyle(color: Colors.black54),
                          )
                        : _buildPerkembanganDetail(),
                  ]),
                  const SizedBox(height: 30),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterDropdown() {
    return Row(
      children: [
        const Text(
          "Bulan:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: _selectedBulan,
          items: _bulanList
              .map((b) => DropdownMenuItem(value: b, child: Text(b)))
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
          "Bulan:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: _selectedTahun,
          items: List.generate(6, (i) {
            int year = DateTime.now().year - i;
            return DropdownMenuItem(value: year, child: Text("$year"));
          }),
          onChanged: (val) {
            setState(() {
              _selectedTahun = val!;
              _applyFilter();
            });
          },
        ),
      ],
    );
  }

  Widget _buildPerkembanganDetail() {
    final p = _filteredPerkembangan!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow("Berat Badan", "${p.beratBadan} kg"),
        _buildRow("Tinggi Badan", "${p.tinggiBadan} cm"),
        _buildRow("Lingkar Lengan", "${p.lingkarLengan} cm"),
        _buildRow("Lingkar Kepala", "${p.lingkarKepala} cm"),
        _buildRow("Cara Ukur", p.caraUkur),
        _buildRow("KMS", p.kms),
        _buildRow("IMD", p.imd),
        _buildRow("Vitamin A", p.vitaminA),
        _buildRow("ASI Eksklusif", p.asiEks),
      ],
    );
  }

  Widget _buildSectionTitle(String title) => Container(
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

  Widget _buildContentCard(List<Widget> children) => Container(
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

  Widget _buildRow(String title, String value) => Padding(
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

  Widget _buildActionButtons() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: ElevatedButton(
          onPressed: _handleUpdate,
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
          onPressed: _handleDelete,
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
