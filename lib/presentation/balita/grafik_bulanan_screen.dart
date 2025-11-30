import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:posyandu_app/core/components/custom_dropdown_button.dart';
import 'package:posyandu_app/core/components/custom_snackbar.dart';
import 'package:posyandu_app/data/models/response/perkembangan_balita/perkembangan_item.dart';
import 'package:posyandu_app/data/models/response/perkembangan_balita/perkembangan_khusus_item.dart';
import 'package:posyandu_app/services/laporan_bulanan.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/repository/perkembangan_balita_repository.dart';

class GrafikBulananScreen extends StatefulWidget {
  const GrafikBulananScreen({super.key});

  @override
  State<GrafikBulananScreen> createState() => _GrafikBulananScreenState();
}

class _GrafikBulananScreenState extends State<GrafikBulananScreen> {
  final PerkembanganBalitaRepository _repository =
      PerkembanganBalitaRepository();

  final List<String> _bulanList = const [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  final List<String> _tipeGrafikList = ['Status Gizi', 'SKDN'];
  String _tipeGrafikDipilih = 'Status Gizi';

  int _s = 0;
  int _k = 0;
  int _d = 0;
  int _n = 0;
  String _persenK = "0";
  String _persenD = "0";
  String _persenN = "0";

  late String _bulanDipilih;
  late int _tahunDipilih;
  late List<int> _tahunList;

  bool _isLoadingChart = true;
  bool _isGeneratingPdf = false;
  bool _isGeneratingPdfKhusus = false;

  int _normal = 0;
  int _kurang = 0;
  int _obesitas = 0;
  int _lakiNormal = 0;
  int _lakiKurang = 0;
  int _lakiObesitas = 0;
  int _perempuanNormal = 0;
  int _perempuanKurang = 0;
  int _perempuanObesitas = 0;
  int _totalLaki = 0;
  int _totalPerempuan = 0;

  @override
  void initState() {
    super.initState();
    _bulanDipilih = _bulanList[DateTime.now().month - 1];
    _tahunDipilih = DateTime.now().year;
    _tahunList = List.generate(5, (i) => DateTime.now().year - i);
    _loadData();
  }

  Future<void> _loadData() async {
    if (_tipeGrafikDipilih == 'Status Gizi') {
      await _fetchStatistik();
    } else {
      await _fetchSKDN();
    }
  }

  Future<void> _fetchSKDN() async {
    setState(() => _isLoadingChart = true);
    final bulanIndex = _bulanList.indexOf(_bulanDipilih) + 1;

    final result = await _repository.getSKDN(
      bulan: bulanIndex,
      tahun: _tahunDipilih,
    );

    result.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(
            message: ("Gagal memuat data SKDN: $error"),
            type: SnackBarType.error,
          ),
        );
        setState(() => _isLoadingChart = false);
      },
      (data) {
        setState(() {
          _s = data.s;
          _k = data.k;
          _d = data.d;
          _n = data.n;
          _persenK = data.persentase.kS;
          _persenD = data.persentase.dS;
          _persenN = data.persentase.nD;
          _isLoadingChart = false;
        });
      },
    );
  }

  Future<void> _fetchStatistik() async {
    setState(() => _isLoadingChart = true);
    final bulanIndex = _bulanList.indexOf(_bulanDipilih) + 1;

    final result = await _repository.getStatistikPerkembangan(
      bulan: bulanIndex,
      tahun: _tahunDipilih,
    );

    result.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(
            message: ("Gagal memuat data grafik: $error"),
            type: SnackBarType.error,
          ),
        );
        setState(() => _isLoadingChart = false);
      },
      (data) {
        try {
          final laki = (data['laki_laki'] ?? {}) as Map<String, dynamic>;
          final perempuan = (data['perempuan'] ?? {}) as Map<String, dynamic>;

          setState(() {
            _normal = (data['normal'] ?? 0) as int;
            _kurang = (data['kurang'] ?? 0) as int;
            _obesitas = (data['obesitas'] ?? 0) as int;
            _totalLaki = (data['total_laki'] ?? 0) as int;
            _totalPerempuan = (data['total_perempuan'] ?? 0) as int;

            _lakiNormal = (laki['normal'] ?? 0) as int;
            _lakiKurang = (laki['kurang'] ?? 0) as int;
            _lakiObesitas = (laki['obesitas'] ?? 0) as int;

            _perempuanNormal = (perempuan['normal'] ?? 0) as int;
            _perempuanKurang = (perempuan['kurang'] ?? 0) as int;
            _perempuanObesitas = (perempuan['obesitas'] ?? 0) as int;

            _isLoadingChart = false;
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar.show(
              message: ("Format data tidak sesuai: $e"),
              type: SnackBarType.error,
            ),
          );
          setState(() => _isLoadingChart = false);
        }
      },
    );
  }

  bool get _isBulanKhusus {
    final bulanIndex = _bulanList.indexOf(_bulanDipilih) + 1;
    return bulanIndex == 2 || bulanIndex == 8;
  }

  Future<void> _generateAndExportPdf({bool isLaporanKhusus = false}) async {
    if (isLaporanKhusus) {
      setState(() => _isGeneratingPdfKhusus = true);
    } else {
      setState(() => _isGeneratingPdf = true);
    }

    try {
      final bulanIndex = _bulanList.indexOf(_bulanDipilih) + 1;
      final int semester;
      final int bulanMulai;
      final int bulanSelesai;

      if (bulanIndex >= 1 && bulanIndex <= 6) {
        semester = 1;
        bulanMulai = 1;
        bulanSelesai = 6;
      } else {
        semester = 2;
        bulanMulai = 7;
        bulanSelesai = 12;
      }

      final detailResult = await _repository.getDetailPerkembanganBulanan(
        bulan: bulanIndex,
        tahun: _tahunDipilih,
      );

      List<PerkembanganItem> detailData = [];

      detailResult.fold(
        (error) {
          print("Gagal mengambil data detail: $error");
        },
        (data) {
          if (data is List) {
            detailData = data.map((item) {
              return PerkembanganItem(
                nama: item['nama'] ?? '',
                nik: item['nik'] ?? '',
                jenisKelamin: item['jenis_kelamin'] ?? '',
                tanggalLahir: item['tanggal_lahir'] ?? '',
                anakKe: item['anak_ke']?.toString() ?? '',
                namaOrtu: item['nama_ortu'] ?? '',
                nikOrtu: item['nik_ortu'] ?? '',
                nomorHpOrtu: item['nomor_hp_ortu'] ?? '',
                alamat: item['alamat'] ?? '',
                rt: item['rt']?.toString() ?? '',
                rw: item['rw']?.toString() ?? '',
                perkembanganBulanan: Map<String, dynamic>.from(
                  item['bulan'] ?? {},
                ),
              );
            }).toList();
          }
        },
      );
      final Uint8List pdfBytes;

      if (isLaporanKhusus) {
        final result = await _repository.getLaporanKhusus(
          bulan: bulanIndex,
          tahun: _tahunDipilih,
        );

        List<PerkembanganKhususItem> listKhusus = [];

        result.fold(
          (error) {
            print("Error laporan khusus: $error");
          },
          (dataList) {
            listKhusus = dataList
                .map((item) => PerkembanganKhususItem.fromJson(item))
                .toList();
          },
        );

        pdfBytes = await LaporanPosyandu.generatePdfKhusus(
          data: listKhusus,
          bulanNama: _bulanDipilih,
          tahun: _tahunDipilih,
        );
      } else {
        pdfBytes = await LaporanPosyandu.generatePdf(
          detail: detailData,
          bulanMulai: bulanMulai,
          bulanSelesai: bulanSelesai,
          bulanNama: _bulanDipilih,
          tahun: _tahunDipilih,
        );
      }

      await LaporanPosyandu.saveAndShare(
        pdfBytes,
        "laporan_posyandu_bulan_$_bulanDipilih.pdf",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.show(
          message:
              ("PDF ${isLaporanKhusus ? 'khusus ' : ''}berhasil di-generate dan siap dicetak"),
          type: SnackBarType.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.show(
          message: ("Gagal generate PDF: $e"),
          type: SnackBarType.error,
        ),
      );
    } finally {
      if (isLaporanKhusus) {
        setState(() => _isGeneratingPdfKhusus = false);
      } else {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  String _getAnalisisGizi(int normal, int kurang, int obesitas, int total) {
    if (total == 0) return "Belum ada data perkembangan bulan ini.";
    final persenNormal = (normal / total) * 100;
    if (persenNormal >= 100) {
      return "Semua balita berada pada kategori gizi normal. Bagus!";
    }
    if (persenNormal >= 70) {
      return "Mayoritas balita normal, namun beberapa perlu perhatian.";
    }
    return "Perlu intervensi karena proporsi gizi kurang/obesitas cukup tinggi.";
  }

  String _getAnalisisSKDN() {
    if (_s == 0) return "Belum ada data balita.";
    return "Data Bulan $_bulanDipilih:\n"
        "• Liputan (K/S): $_persenK%\n"
        "• Partisipasi (D/S): $_persenD%\n"
        "• Keberhasilan (N/D): $_persenN%";
  }

  Color _getPerformanceColor(double percentage) {
    if (percentage >= 0.8) return Colors.green;
    if (percentage >= 0.5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final int totalBalita = (_tipeGrafikDipilih == 'SKDN')
        ? _s
        : (_normal + _kurang + _obesitas);

    List<_GrafikData> chartData = [];
    if (_tipeGrafikDipilih == 'SKDN') {
      chartData = [
        _GrafikData('S', _s, Colors.red),
        _GrafikData('K', _k, Colors.yellow.shade800),
        _GrafikData('D', _d, Colors.green),
        _GrafikData('N', _n, Colors.blue),
      ];
    } else {
      chartData = [
        _GrafikData('Obesitas', _obesitas, Colors.redAccent),
        _GrafikData('Kurang', _kurang, Colors.orangeAccent),
        _GrafikData('Normal', _normal, Colors.green),
      ];
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Grafik Gizi dan SKDN",
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
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _FilterSliverDelegate(
              minHeight: 160,
              maxHeight: 160,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: Colors.white,
                          value: _tipeGrafikDipilih,
                          icon: const Icon(
                            Icons.bar_chart,
                            color: AppColors.primary,
                          ),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          isExpanded: true,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() => _tipeGrafikDipilih = newValue);
                              _loadData();
                            }
                          },
                          items: _tipeGrafikList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildSimpleDropdown(
                            value: _bulanDipilih,
                            items: _bulanList,
                            onChanged: (val) {
                              setState(() => _bulanDipilih = val!);
                              _loadData();
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: _buildSimpleDropdown(
                            value: _tahunDipilih.toString(),
                            items: _tahunList.map((e) => e.toString()).toList(),
                            onChanged: (val) {
                              setState(() => _tahunDipilih = int.parse(val!));
                              _loadData();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Card(
                elevation: 4,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Visualisasi Data",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          Icon(Icons.bar_chart, color: AppColors.primary),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: _isLoadingChart
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              )
                            : SfCartesianChart(
                                key: ValueKey(_tipeGrafikDipilih),
                                plotAreaBorderWidth: 0,
                                primaryXAxis: CategoryAxis(
                                  majorGridLines: const MajorGridLines(
                                    width: 0,
                                  ),
                                  labelStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                primaryYAxis: NumericAxis(
                                  axisLine: const AxisLine(width: 0),
                                  majorTickLines: const MajorTickLines(size: 0),
                                  majorGridLines: MajorGridLines(
                                    width: 0.5,
                                    color: Colors.grey[200],
                                    dashArray: [5, 5],
                                  ),
                                  interval: _tipeGrafikDipilih == 'SKDN'
                                      ? null
                                      : 1,
                                ),
                                tooltipBehavior: TooltipBehavior(enable: true),
                                series: <CartesianSeries<_GrafikData, String>>[
                                  ColumnSeries<_GrafikData, String>(
                                    dataSource: chartData,
                                    xValueMapper: (data, _) => data.kategori,
                                    yValueMapper: (data, _) => data.jumlah,
                                    pointColorMapper: (data, _) => data.warna,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(6),
                                    ),
                                    dataLabelSettings: const DataLabelSettings(
                                      isVisible: true,
                                      labelAlignment:
                                          ChartDataLabelAlignment.middle,
                                      textStyle: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.grid_view_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Rincian ${_tipeGrafikDipilih}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _tipeGrafikDipilih == 'Status Gizi'
                          ? _buildModernGiziLayout(totalBalita)
                          : _buildCleanSKDNLayout(),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 18,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _tipeGrafikDipilih == 'Status Gizi'
                                    ? _getAnalisisGizi(
                                        _normal,
                                        _kurang,
                                        _obesitas,
                                        totalBalita,
                                      )
                                    : _getAnalisisSKDN(),
                                style: TextStyle(
                                  color: Colors.orange[900],
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              child: Column(
                children: [
                  if (_tipeGrafikDipilih == 'Status Gizi') ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isGeneratingPdf
                            ? null
                            : _generateAndExportPdf,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        icon: _isGeneratingPdf
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.picture_as_pdf_outlined,
                                color: Colors.white,
                              ),
                        label: Text(
                          _isGeneratingPdf
                              ? "Memproses..."
                              : "Download Laporan Bulanan",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (_isBulanKhusus) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _isGeneratingPdfKhusus
                              ? null
                              : () => _generateAndExportPdf(
                                  isLaporanKhusus: true,
                                ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.orange),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: _isGeneratingPdfKhusus
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.orange,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.star_outline,
                                  color: Colors.orange,
                                ),
                          label: Text(
                            _isGeneratingPdfKhusus
                                ? "Memproses..."
                                : "Download Laporan Khusus",
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ] else ...[
                    // TOMBOL SKDN (Bisa ditekan tapi menampilkan SnackBar)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            CustomSnackBar.show(
                              message: "Fitur belum tersedia",
                              type: SnackBarType.info,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        icon: const Icon(
                          Icons.picture_as_pdf_outlined,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Download Laporan SKDN",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.white,
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          onChanged: onChanged,
          items: items.map((String val) {
            return DropdownMenuItem<String>(value: val, child: Text(val));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildModernGiziLayout(int total) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ringkasan Balita",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildSummaryBadge("Total", "$total", Colors.blueGrey),
                      const SizedBox(width: 8),
                      _buildSummaryBadge("L", "$_totalLaki", Colors.blue),
                      const SizedBox(width: 8),
                      _buildSummaryBadge("P", "$_totalPerempuan", Colors.pink),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildGiziDetailCard(
          title: "Gizi Normal",
          color: Colors.green,
          total: _normal,
          male: _lakiNormal,
          female: _perempuanNormal,
        ),
        const SizedBox(height: 12),
        _buildGiziDetailCard(
          title: "Gizi Kurang",
          color: Colors.orange,
          total: _kurang,
          male: _lakiKurang,
          female: _perempuanKurang,
        ),
        const SizedBox(height: 12),
        _buildGiziDetailCard(
          title: "Obesitas",
          color: Colors.red,
          total: _obesitas,
          male: _lakiObesitas,
          female: _perempuanObesitas,
        ),
      ],
    );
  }

  Widget _buildSummaryBadge(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          Text(
            count,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiziDetailCard({
    required String title,
    required Color color,
    required int total,
    required int male,
    required int female,
  }) {
    double totalVal = total == 0 ? 1 : total.toDouble();
    double malePct = male / totalVal;
    double femalePct = female / totalVal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$total",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: (malePct * 100).toInt(),
                    child: Container(color: Colors.blue.shade300),
                  ),
                  Expanded(
                    flex: (femalePct * 100).toInt(),
                    child: Container(color: Colors.pink.shade300),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.male, size: 14, color: Colors.blue.shade400),
                  const SizedBox(width: 4),
                  Text(
                    "Laki-laki: $male",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "Perempuan: $female",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.female, size: 14, color: Colors.pink.shade400),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCleanSKDNLayout() {
    return Column(
      children: [
        _buildCleanSKDNCard(
          title: "Sasaran Balita (S)",
          count: _s,
          identityColor: Colors.red,
          formula: null,
          percentageValue: 0,
          percentageText: "-",
        ),
        const SizedBox(height: 12),
        _buildCleanSKDNCard(
          title: "Punya KMS (K)",
          count: _k,
          identityColor: Colors.yellow.shade800,
          formula: "Target: K / S",
          percentageValue: (double.tryParse(_persenK) ?? 0) / 100,
          percentageText: "$_persenK%",
        ),
        const SizedBox(height: 12),
        _buildCleanSKDNCard(
          title: "Datang Ditimbang (D)",
          count: _d,
          identityColor: Colors.green,
          formula: "Target: D / S",
          percentageValue: (double.tryParse(_persenD) ?? 0) / 100,
          percentageText: "$_persenD%",
        ),
        const SizedBox(height: 12),
        _buildCleanSKDNCard(
          title: "Naik Berat Badan (N)",
          count: _n,
          identityColor: Colors.blue,
          formula: "Target: N / D",
          percentageValue: (double.tryParse(_persenN) ?? 0) / 100,
          percentageText: "$_persenN%",
        ),
      ],
    );
  }

  Widget _buildCleanSKDNCard({
    required String title,
    required int count,
    required Color identityColor,
    String? formula,
    required double percentageValue,
    required String percentageText,
  }) {
    final Color performanceColor = formula == null
        ? identityColor
        : _getPerformanceColor(percentageValue);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: identityColor.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$count Data",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 30,
                  height: 3,
                  decoration: BoxDecoration(
                    color: identityColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          if (formula != null) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  percentageText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: performanceColor,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    formula,
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                children: [
                  CircularProgressIndicator(
                    value: percentageValue > 1.0 ? 1.0 : percentageValue,
                    strokeWidth: 4,
                    backgroundColor: Colors.grey[100],
                    color: performanceColor,
                  ),
                ],
              ),
            ),
          ] else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Total",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterSliverDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  _FilterSliverDelegate({
    required this.child,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_FilterSliverDelegate oldDelegate) {
    return true;
  }
}

class _GrafikData {
  final String kategori;
  final dynamic jumlah;
  final Color warna;
  _GrafikData(this.kategori, this.jumlah, this.warna);
}
