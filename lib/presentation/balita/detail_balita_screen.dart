import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:posyandu_app/data/repository/balita_repository.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/models/response/balita/balita_response.dart';
import 'package:posyandu_app/data/models/response/perkembangan_balita/perkembangan_balita_reponse.dart';
import 'package:posyandu_app/data/repository/perkembangan_balita_repository.dart';
import 'package:posyandu_app/presentation/perkembanganBalita/tambah_perkembangan_balita.dart';
import 'package:posyandu_app/presentation/balita/tambah_balita_screen.dart'; // Import tambahan

class DetailBalitaScreen extends StatefulWidget {
  final BalitaResponseModel balita;

  const DetailBalitaScreen({super.key, required this.balita});

  @override
  State<DetailBalitaScreen> createState() => _DetailBalitaScreenState();
}

class _DetailBalitaScreenState extends State<DetailBalitaScreen> {
  final PerkembanganBalitaRepository _repository =
      PerkembanganBalitaRepository();
  final BalitaRepository _balitaRepository = BalitaRepository();

  int _hitungUmurBulan(DateTime tglLahir) {
    final now = DateTime.now();
    int bulan = (now.year - tglLahir.year) * 12 + (now.month - tglLahir.month);

    if (now.day < tglLahir.day) bulan--;

    return bulan < 0 ? 0 : bulan;
  }

  Color _warnaVitaminABerdasarkanUmur(DateTime tglLahir) {
    final umurBulan = _hitungUmurBulan(tglLahir);

    if (umurBulan >= 6 && umurBulan <= 11) {
      return Colors.blue;
    } else if (umurBulan >= 12 && umurBulan <= 60) {
      return Colors.red;
    }

    return Colors.black;
  }

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
    final balitaResult = await _balitaRepository.getBalitaByNIK(
      widget.balita.nikBalita,
    );

    balitaResult.fold(
      (error) {
        log("Gagal memuat data balita terbaru: $error");
      },
      (updatedBalita) {
        try {
          final tglLahir = DateTime.parse(updatedBalita.tanggalLahir);
          setState(() {
            _warnaNama = _warnaVitaminABerdasarkanUmur(tglLahir);
          });
        } catch (e) {
          setState(() => _warnaNama = Colors.black);
        }
      },
    );

    final result = await _repository.getPerkembanganByNIK(
      widget.balita.nikBalita,
    );

    result.fold(
      (error) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data perkembangan: $error")),
        );
      },
      (dataList) {
        dataList.sort((a, b) {
          final dateA = _safeParseDate(a.tanggalPerubahan);
          final dateB = _safeParseDate(b.tanggalPerubahan);
          return dateB.compareTo(dateA);
        });

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

  String _formatTanggalIndonesia(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "-";
    try {
      final date = DateTime.parse(rawDate);
      return DateFormat("d MMMM yyyy", "id_ID").format(date);
    } catch (e) {
      return rawDate;
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

  Future<void> _handleUpdateBalita() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TambahBalitaScreen(isEdit: true, data: widget.balita),
      ),
    );

    if (updated == true) {
      _fetchPerkembangan();
    }
  }

  Future<void> _handleDeleteBalita() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: Text(
          "Apakah kamu yakin ingin menghapus data balita ${widget.balita.namaBalita}?",
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

    if (confirm != true) return;

    final result = await _balitaRepository.deleteBalita(
      widget.balita.nikBalita,
    );

    result.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menghapus balita: $error"),
            backgroundColor: Colors.red,
          ),
        );
      },
      (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success), backgroundColor: Colors.green),
        );

        Navigator.of(context).pop(true);
      },
    );
  }

  Future<void> _handleUpdatePerkembangan() async {
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

  Future<void> _handleDeletePerkembangan() async {
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
                                fontSize: 14,
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
                    _buildRow("NIK Orang Tua", widget.balita.nikOrtu),
                    _buildRow("Nomor Telepon", widget.balita.nomorTelpOrtu),
                    _buildRow("Alamat", widget.balita.alamat),
                  ]),
                  const SizedBox(height: 20),
                  _buildActionButtonsBalita(),
                  const SizedBox(height: 20),

                  _buildSectionTitle("Data Perkembangan Balita"),
                  _buildContentCard([
                    _buildGrafikPerkembangan(),
                    const SizedBox(height: 8),
                    _filteredPerkembangan == null
                        ? const Text(
                            "Belum ada data perkembangan untuk bulan ini.",
                            style: TextStyle(color: Colors.black54),
                          )
                        : _buildPerkembanganDetail(),
                  ]),
                  const SizedBox(height: 30),

                  _buildActionButtonsPerkembangan(),
                ],
              ),
            ),
    );
  }

  Widget _buildActionButtonsBalita() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: ElevatedButton(
          onPressed: _handleUpdateBalita,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("Perbarui Data Balita")],
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          onPressed: _handleDeleteBalita,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("Hapus Data Balita")],
          ),
        ),
      ),
    ],
  );

  Widget _buildActionButtonsPerkembangan() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: ElevatedButton(
          onPressed: _handleUpdatePerkembangan,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("Perbarui Perkembangan")],
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          onPressed: _handleDeletePerkembangan,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("Hapus Perkembangan")],
          ),
        ),
      ),
    ],
  );

  Widget _buildGrafikPerkembangan() {
    if (_perkembanganList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "Belum ada data perkembangan balita.",
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    final List<String> jenisDataList = [
      "Berat Badan (kg)",
      "Tinggi Badan (cm)",
      "Lingkar Lengan (cm)",
      "Lingkar Kepala (cm)",
    ];

    String selectedJenis = "Berat Badan (kg)";

    return StatefulBuilder(
      builder: (context, setLocalState) {
        final selectedMonthIndex = _bulanList.indexOf(_selectedBulan) + 1;
        final selectedYear = _selectedTahun;

        List<DateTime> lastFiveMonths = List.generate(5, (i) {
          final date = DateTime(selectedYear, selectedMonthIndex - 4 + i);
          return DateTime(date.year, date.month);
        });

        final filteredData = _perkembanganList.where((e) {
          final date = _safeParseDate(e.tanggalPerubahan);
          return lastFiveMonths.any(
            (m) => m.month == date.month && m.year == date.year,
          );
        }).toList();

        List<_GrafikBalitaData> chartData = lastFiveMonths.map((month) {
          final bulanNama = _bulanList[(month.month - 1) % 12].substring(0, 3);
          final dataBulan = filteredData.firstWhere(
            (d) {
              final tgl = _safeParseDate(d.tanggalPerubahan);
              return tgl.month == month.month && tgl.year == month.year;
            },
            orElse: () => PerkembanganBalitaResponseModel(
              id: 0,
              tanggalPerubahan: '',
              caraUkur: '',
              imd: '',
              kms: '',
              vitaminA: '',
              asiEks: '',
              createdAt: '',
              nikBalita: '',
              beratBadan: 0,
              tinggiBadan: 0,
              lingkarLengan: 0,
              lingkarKepala: 0,
            ),
          );

          double value;
          switch (selectedJenis) {
            case "Tinggi Badan (cm)":
              value = dataBulan.tinggiBadan.toDouble();
              break;
            case "Lingkar Lengan (cm)":
              value = dataBulan.lingkarLengan.toDouble();
              break;
            case "Lingkar Kepala (cm)":
              value = dataBulan.lingkarKepala.toDouble();
              break;
            default:
              value = dataBulan.beratBadan.toDouble();
          }

          return _GrafikBalitaData("$bulanNama\n${month.year}", value);
        }).toList();

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _modernDropdown<String>(
                      label: "Bulan",
                      value: _selectedBulan,
                      items: _bulanList,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedBulan = val;
                            _applyFilter();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _modernDropdown<int>(
                      label: "Tahun",
                      value: _selectedTahun,
                      items: List.generate(6, (i) => DateTime.now().year - i),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedTahun = val;
                            _applyFilter();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              _modernDropdown<String>(
                label: "Jenis Data",
                value: selectedJenis,
                items: jenisDataList,
                onChanged: (val) {
                  if (val != null) {
                    setLocalState(() => selectedJenis = val);
                  }
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 250,
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  backgroundColor: Colors.transparent,
                  primaryXAxis: CategoryAxis(
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    axisLine: const AxisLine(width: 0),
                    majorGridLines: const MajorGridLines(width: 0),
                  ),
                  primaryYAxis: NumericAxis(
                    labelStyle: const TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                    ),
                    axisLine: const AxisLine(width: 0),
                    majorGridLines: const MajorGridLines(
                      color: Color(0xFFE0E0E0),
                      width: 0.6,
                    ),
                  ),
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    color: Colors.white,
                    borderColor: Colors.grey.shade300,
                    borderWidth: 0.8,
                    textStyle: const TextStyle(color: Colors.black),
                    canShowMarker: false,
                  ),
                  series: <CartesianSeries<_GrafikBalitaData, String>>[
                    SplineSeries<_GrafikBalitaData, String>(
                      dataSource: chartData,
                      xValueMapper: (data, _) => data.bulan,
                      yValueMapper: (data, _) => data.nilai,
                      width: 3,
                      color: AppColors.primary,
                      markerSettings: const MarkerSettings(
                        isVisible: true,
                        shape: DataMarkerType.circle,
                        borderWidth: 2,
                        borderColor: AppColors.primary,
                        height: 8,
                        width: 8,
                      ),
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _modernDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required Function(T?) onChanged,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.only(right: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                isExpanded: true,
                value: value,
                items: items
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          "$item",
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
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
}

class _GrafikBalitaData {
  final String bulan;
  final double nilai;
  _GrafikBalitaData(this.bulan, this.nilai);
}
