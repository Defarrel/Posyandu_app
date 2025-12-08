import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:posyandu_app/core/components/custom_snackbar.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/models/response/balita/balita_response.dart';
import 'package:posyandu_app/data/models/response/perkembangan_balita/perkembangan_balita_reponse.dart';
import 'package:posyandu_app/data/repository/balita_repository.dart';
import 'package:posyandu_app/data/repository/perkembangan_balita_repository.dart';
import 'package:posyandu_app/presentation/balita/tambah_balita_screen.dart';
import 'package:posyandu_app/presentation/perkembanganBalita/tambah_perkembangan_balita.dart';
import 'package:posyandu_app/core/util/antropometri_data.dart';

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
    if (umurBulan >= 6 && umurBulan <= 11) return const Color(0xFF2196F3);
    if (umurBulan >= 12 && umurBulan <= 59) return const Color(0xFFF44336);
    return Colors.grey.shade400;
  }

  String _labelVitaminABerdasarkanUmur(DateTime tglLahir) {
    final umurBulan = _hitungUmurBulan(tglLahir);
    if (umurBulan >= 6 && umurBulan <= 11) return "Vit A Biru";
    if (umurBulan >= 12 && umurBulan <= 59) return "Vit A Merah";
    return "Non Vit-A";
  }

  String _formatPhone(String phone) {
    if (phone.isEmpty) return "-";
    String cleanPhone = phone.replaceAll("-", "").replaceAll(" ", "");
    if (cleanPhone.length <= 4) return cleanPhone;
    List<String> chunks = [];
    for (int i = 0; i < cleanPhone.length; i += 4) {
      int end = (i + 4 < cleanPhone.length) ? i + 4 : cleanPhone.length;
      chunks.add(cleanPhone.substring(i, end));
    }
    return chunks.join("-");
  }

  String _formatJenisKelamin(String jk) {
    if (jk.toUpperCase() == 'L') return "Laki-laki";
    if (jk.toUpperCase() == 'P') return "Perempuan";
    return jk;
  }

  String hitungUmur(String tanggalLahir) {
    try {
      DateTime lahir = DateTime.parse(tanggalLahir);
      DateTime now = DateTime.now();

      int tahun = now.year - lahir.year;
      int bulan = now.month - lahir.month;
      int hari = now.day - lahir.day;

      if (hari < 0) {
        bulan -= 1;
        hari += DateTime(now.year, now.month, 0).day;
      }

      if (bulan < 0) {
        tahun -= 1;
        bulan += 12;
      }

      if (tahun < 0) return "-";

      if (tahun == 0 && bulan == 0) {
        return "$hari hari";
      } else if (tahun == 0) {
        return "$bulan bulan";
      } else {
        return "$tahun thn $bulan bln";
      }
    } catch (e) {
      return "-";
    }
  }

  String _formatTanggal(String raw) {
    try {
      final date = DateTime.parse(raw);
      return DateFormat("d MMM yyyy", "id_ID").format(date);
    } catch (_) {
      return raw;
    }
  }

  DateTime _safeParseDate(String? raw) {
    if (raw == null || raw.isEmpty) return DateTime(1900);
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return DateTime(1900);
    }
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

  late String _selectedBulan;
  late int _selectedTahun;
  late BalitaResponseModel _balitaData;
  String _selectedChartType = "Berat Badan (kg)";

  @override
  void initState() {
    super.initState();
    _balitaData = widget.balita;
    _selectedTahun = DateTime.now().year;
    initializeDateFormatting('id_ID', null);
    _selectedBulan = _bulanList[DateTime.now().month - 1];
    _fetchPerkembangan();
  }


  Future<void> _fetchPerkembangan() async {
    final balitaResult = await _balitaRepository.getBalitaByNIK(
      widget.balita.nikBalita,
    );
    balitaResult.fold((l) => log("Error refresh balita: $l"), (r) {
      if (mounted) setState(() => _balitaData = r);
    });

    final result = await _repository.getPerkembanganByNIK(
      widget.balita.nikBalita,
    );
    result.fold(
      (error) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar.show(
              message: "Gagal: $error",
              type: SnackBarType.error,
            ),
          );
        }
      },
      (dataList) {
        dataList.sort((a, b) {
          final dateA = _safeParseDate(a.tanggalPerubahan);
          final dateB = _safeParseDate(b.tanggalPerubahan);
          return dateB.compareTo(dateA);
        });

        if (mounted) {
          setState(() {
            _perkembanganList = dataList;
            _applyFilter();
            _isLoading = false;
          });
        }
      },
    );
  }

  void _applyFilter() {
    final bulanIndex = _bulanList.indexOf(_selectedBulan) + 1;
    final filtered = _perkembanganList.where((data) {
      final tgl = _safeParseDate(data.tanggalPerubahan);
      return tgl.month == bulanIndex && tgl.year == _selectedTahun;
    }).toList();

    setState(() {
      _filteredPerkembangan = filtered.isNotEmpty ? filtered.first : null;
    });
  }


  Future<void> _handleEditBalita() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TambahBalitaScreen(isEdit: true, data: _balitaData),
      ),
    );
    if (updated == true) _fetchPerkembangan();
  }

  Future<void> _handleDeleteBalita() async {
    final confirm = await _showConfirmDialog(
      "Hapus Data Balita?",
      "Data yang dihapus tidak dapat dikembalikan.",
    );
    if (!confirm) return;

    final result = await _balitaRepository.deleteBalita(_balitaData.nikBalita);
    result.fold(
      (l) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(CustomSnackBar.show(message: l, type: SnackBarType.error)),
      (r) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(message: r, type: SnackBarType.success),
        );
        Navigator.pop(context, true);
      },
    );
  }

  Future<void> _handleUpdatePerkembangan() async {
    DateTime tglLahir;
    try {
      tglLahir = DateTime.parse(_balitaData.tanggalLahir);
    } catch (e) {
      tglLahir = DateTime.now();
    }

    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TambahPerkembanganBalita(
          nikBalita: _balitaData.nikBalita,
          namaBalita: _balitaData.namaBalita,
          jenisKelamin: _balitaData.jenisKelamin,
          tanggalLahir: tglLahir,
          existingData: _filteredPerkembangan,
        ),
      ),
    );
    if (updated == true) _fetchPerkembangan();
  }

  Future<void> _handleDeletePerkembangan() async {
    if (_filteredPerkembangan == null) return;
    final confirm = await _showConfirmDialog(
      "Hapus Perkembangan?",
      "Data bulan ini akan dihapus.",
    );
    if (!confirm) return;

    final result = await _repository.deletePerkembangan(
      _filteredPerkembangan!.id,
    );
    result.fold(
      (l) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(CustomSnackBar.show(message: l, type: SnackBarType.error)),
      (r) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(message: r, type: SnackBarType.success),
        );
        _fetchPerkembangan();
      },
    );
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  "Hapus",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Detail Balita",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onSelected: (val) {
              if (val == 'edit') _handleEditBalita();
              if (val == 'delete') _handleDeleteBalita();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: AppColors.primary, size: 18),
                    SizedBox(width: 8),
                    Text("Edit Biodata"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text("Hapus Balita", style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: _fetchPerkembangan,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 16),
                    _buildBiodataCard(),
                    const SizedBox(height: 24),
                    _buildChartSection(),
                    const SizedBox(height: 24),
                    _buildMonthFilter(),
                    const SizedBox(height: 16),
                    _buildGrowthStatsGrid(),
                    const SizedBox(height: 16),
                    _buildAdditionalInfo(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    DateTime tglLahir = DateTime.now();
    try {
      tglLahir = DateTime.parse(_balitaData.tanggalLahir);
    } catch (_) {}

    Color vitaminColor = _warnaVitaminABerdasarkanUmur(tglLahir);
    String vitaminLabel = _labelVitaminABerdasarkanUmur(tglLahir);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _balitaData.namaBalita,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  vitaminLabel,
                  style: TextStyle(
                    color: vitaminColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildHeaderChip(
                Icon(
                  _balitaData.jenisKelamin.toLowerCase().contains('l')
                      ? Icons.male
                      : Icons.female,
                  color: Colors.white,
                  size: 14,
                ),
                _formatJenisKelamin(_balitaData.jenisKelamin),
              ),
              _buildHeaderChip(
                const Icon(Icons.cake, color: Colors.white, size: 14),
                _formatTanggal(_balitaData.tanggalLahir),
              ),
              _buildHeaderChip(
                const Icon(Icons.child_care, color: Colors.white, size: 14),
                "Anak ke-${_balitaData.anakKeBerapa}",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderChip(Widget icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildBiodataCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Informasi Balita", Icons.person_outline),
          _infoRow("NIK Balita", _balitaData.nikBalita),
          _infoRow("Umur Balita", hitungUmur(_balitaData.tanggalLahir)),

          _infoRow(
            "Jenis Kelamin",
            _formatJenisKelamin(_balitaData.jenisKelamin),
          ),
          _infoRow("Anak Ke-", "${_balitaData.anakKeBerapa}"),
          _infoRow("BB lahir", "${_balitaData.bbLahir} kg"),
          _infoRow("TB Lahir", "${_balitaData.tbLahir} cm"),
          _infoRow("Nomor KK", _balitaData.nomorKk),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _buildSectionHeader("Informasi Orang Tua", Icons.family_restroom),
          _infoRow("Nama Orang Tua", _balitaData.namaOrtu),
          _infoRow("NIK Orang Tua", _balitaData.nikOrtu),
          _infoRow("No. Telepon", _formatPhone(_balitaData.nomorTelpOrtu)),
          _infoRow("Alamat", _balitaData.alamat),
          _infoRow("RT/RW", "${_balitaData.rt} / ${_balitaData.rw}"),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Grafik Pertumbuhan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedChartType,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  items:
                      [
                        "Berat Badan (kg)",
                        "Tinggi Badan (cm)",
                        "Lingkar Kepala (cm)",
                        "Lingkar Lengan (cm)",
                      ].map((e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedChartType = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 220, child: _buildChartWidget()),
        ],
      ),
    );
  }

  Widget _buildChartWidget() {
    final selectedMonthIndex = _bulanList.indexOf(_selectedBulan) + 1;
    List<DateTime> lastMonths = List.generate(6, (i) {
      final date = DateTime(_selectedTahun, selectedMonthIndex - 5 + i);
      return DateTime(date.year, date.month);
    });

    List<_ChartData> chartData = lastMonths.map((month) {
      final bulanStr = _bulanList[(month.month - 1) % 12].substring(0, 3);
      final data = _perkembanganList.firstWhere(
        (d) {
          final tgl = _safeParseDate(d.tanggalPerubahan);
          return tgl.month == month.month && tgl.year == month.year;
        },
        orElse: () => PerkembanganBalitaResponseModel(
          id: 0,
          tanggalPerubahan: '',
          beratBadan: 0,
          tinggiBadan: 0,
          lingkarLengan: 0,
          lingkarKepala: 0,
          caraUkur: '',
          imd: '',
          kms: '',
          vitaminA: '',
          asiEks: '',
          createdAt: '',
          nikBalita: '',
        ),
      );

      double val = 0;
      if (_selectedChartType.contains("Berat"))
        val = data.beratBadan.toDouble();
      else if (_selectedChartType.contains("Tinggi"))
        val = data.tinggiBadan.toDouble();
      else if (_selectedChartType.contains("Kepala"))
        val = data.lingkarKepala.toDouble();
      else
        val = data.lingkarLengan.toDouble();

      return _ChartData(
        "$bulanStr\n${month.year.toString().substring(2)}",
        val,
      );
    }).toList();

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: const TextStyle(fontSize: 10),
      ),
      primaryYAxis: NumericAxis(
        axisLine: const AxisLine(width: 0),
        majorGridLines: MajorGridLines(width: 0.5, color: Colors.grey.shade200),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<_ChartData, String>>[
        SplineAreaSeries<_ChartData, String>(
          dataSource: chartData,
          xValueMapper: (data, _) => data.label,
          yValueMapper: (data, _) => data.value,
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.2),
              AppColors.primary.withOpacity(0.01),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderColor: AppColors.primary,
          borderWidth: 2,
          markerSettings: const MarkerSettings(
            isVisible: true,
            height: 8,
            width: 8,
            color: Colors.white,
            borderColor: AppColors.primary,
            borderWidth: 2,
          ),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            textStyle: TextStyle(
              color: AppColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthFilter() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedBulan,
                isExpanded: true,
                items: _bulanList.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null)
                    setState(() {
                      _selectedBulan = val;
                      _applyFilter();
                    });
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedTahun,
                isExpanded: true,
                items: List.generate(5, (i) => DateTime.now().year - i).map((
                  e,
                ) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text("$e", style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null)
                    setState(() {
                      _selectedTahun = val;
                      _applyFilter();
                    });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthStatsGrid() {
    if (_filteredPerkembangan == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.notes, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              "Statistik $_selectedBulan $_selectedTahun",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _handleUpdatePerkembangan,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Input Data"),
            ),
          ],
        ),
      );
    }

    final p = _filteredPerkembangan!;

    DateTime tglLahir = DateTime.now();
    try {
      tglLahir = DateTime.parse(_balitaData.tanggalLahir);
    } catch (_) {}

    DateTime tglUkur = DateTime.now();
    try {
      tglUkur = DateTime.parse(p.tanggalPerubahan);
    } catch (_) {}

    int umurSaatUkur =
        (tglUkur.year - tglLahir.year) * 12 + (tglUkur.month - tglLahir.month);
    if (tglUkur.day < tglLahir.day) umurSaatUkur--;
    if (umurSaatUkur < 0) umurSaatUkur = 0;


    String statusGiziBBU = getKategoriStatusGizi(
      p.beratBadan.toDouble(),
      _balitaData.jenisKelamin,
      umurSaatUkur,
    );
    Color warnaStatusBBU = getColorStatusGizi(statusGiziBBU);

    String statusGiziTBU = getStatusTinggiUmur(
      p.tinggiBadan.toDouble(),
      _balitaData.jenisKelamin,
      umurSaatUkur,
    );
    Color warnaStatusTBU = getColorStatusGizi(statusGiziTBU);

    String statusGiziBBTB = getStatusBeratTinggi(
      p.beratBadan.toDouble(),
      p.tinggiBadan.toDouble(),
      _balitaData.jenisKelamin,
      umurSaatUkur,
    );
    Color warnaStatusBBTB = getColorStatusGizi(statusGiziBBTB);

    String rekomendasiBB = getRekomendasiBerat(
      umurSaatUkur,
      _balitaData.jenisKelamin,
    );

    String rekomendasiTB = getRekomendasiTinggi(
      umurSaatUkur,
      _balitaData.jenisKelamin,
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Statistik $_selectedBulan $_selectedTahun",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Row(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.edit,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  onPressed: _handleUpdatePerkembangan,
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: _handleDeletePerkembangan,
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),

        _buildStatusCard("BB/U (Berat/Umur)", statusGiziBBU, warnaStatusBBU),
        const SizedBox(height: 8),
        _buildStatusCard("TB/U (Tinggi/Umur)", statusGiziTBU, warnaStatusTBU),
        const SizedBox(height: 8),
        _buildStatusCard(
          "BB/TB (Berat/Tinggi)",
          statusGiziBBTB,
          warnaStatusBBTB,
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.monitor_weight_outlined,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Target BB:",
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rekomendasiBB,
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.height,
                          size: 16,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Target TB:",
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rekomendasiTB,
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _statCard(
              Icons.monitor_weight_outlined,
              "Berat Badan",
              "${p.beratBadan}",
              "kg",
              Colors.blue.shade50,
              Colors.blue,
            ),
            _statCard(
              Icons.height,
              "Tinggi Badan",
              "${p.tinggiBadan}",
              "cm",
              Colors.orange.shade50,
              Colors.orange,
            ),
            _statCard(
              Icons.circle_outlined,
              "Lingkar Kepala",
              "${p.lingkarKepala}",
              "cm",
              Colors.purple.shade50,
              Colors.purple,
            ),
            _statCard(
              Icons.accessibility_new,
              "Lingkar Lengan",
              "${p.lingkarLengan}",
              "cm",
              Colors.green.shade50,
              Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard(String title, String status, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: const Icon(
              Icons.health_and_safety,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    IconData icon,
    String title,
    String value,
    String unit,
    Color bgColor,
    Color accentColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextSpan(
                  text: " $unit",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    if (_filteredPerkembangan == null) return const SizedBox();
    final p = _filteredPerkembangan!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Catatan Kesehatan",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Divider(height: 20),
          _infoRow("Cara Ukur", p.caraUkur),
          _infoRow("KMS", p.kms),
          _infoRow("Vitamin A", p.vitaminA),
          _infoRow("ASI Eksklusif", p.asiEks),
          _infoRow("IMD", p.imd),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartData {
  final String label;
  final double value;
  _ChartData(this.label, this.value);
}
