import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:posyandu_app/core/components/custom_dropdown_button.dart';
import 'package:posyandu_app/core/components/custom_snackbar.dart';
import 'package:posyandu_app/data/models/response/perkembangan_balita/perkembangan_item.dart';
import 'package:posyandu_app/data/models/response/perkembangan_balita/perkembangan_khusus_item.dart';
import 'package:posyandu_app/presentation/balita/laporan_bulanan.dart';
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
    _fetchStatistik();
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
    final persenKurang = (kurang / total) * 100;
    final persenObes = (obesitas / total) * 100;
    final persenMasalah = persenKurang + persenObes;

    if (persenNormal >= 100) {
      return "Semua balita berada pada kategori gizi normal (${persenNormal.toStringAsFixed(1)}%). Tidak ada tindakan khusus yang diperlukan.";
    } else if (persenNormal >= 70) {
      return "Mayoritas balita dalam kategori gizi normal (${persenNormal.toStringAsFixed(1)}%). Namun, ${persenMasalah.toStringAsFixed(1)}% anak masih perlu perhatian karena mengalami gizi kurang atau obesitas.";
    } else if (persenKurang > persenObes) {
      return "Perhatian: proporsi gizi kurang tinggi (${persenKurang.toStringAsFixed(1)}%). Disarankan intervensi nutrisi.";
    } else if (persenObes > persenKurang) {
      return "Perhatian: proporsi obesitas tinggi (${persenObes.toStringAsFixed(1)}%). Disarankan evaluasi pola makan.";
    } else {
      return "Distribusi status gizi bervariasi — tetap pantau dan tindak lanjut sesuai kebutuhan.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalBalita = _normal + _kurang + _obesitas;
    final List<_GrafikData> chartData = [
      _GrafikData('Obesitas', _obesitas, Colors.redAccent),
      _GrafikData('Kurang', _kurang, Colors.orangeAccent),
      _GrafikData('Normal', _normal, Colors.green),
    ];

    final total = _normal + _kurang + _obesitas;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Grafik Perkembangan Balita",
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
      body: RefreshIndicator(
        onRefresh: _fetchStatistik,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.95),
                      AppColors.accent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Grafik Balita Bulan ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomDropdownButton(
                                value: _bulanDipilih,
                                items: _bulanList,
                                isCompact: true,
                                textColor: Colors.white,
                                onChanged: (value) async {
                                  setState(() => _bulanDipilih = value ?? '');
                                  await _fetchStatistik();
                                },
                              ),
                              const SizedBox(width: 4),
                              CustomDropdownButton(
                                value: _tahunDipilih.toString(),
                                items: _tahunList
                                    .map((t) => t.toString())
                                    .toList(),
                                isCompact: true,
                                textColor: Colors.white,
                                onChanged: (value) async {
                                  setState(
                                    () => _tahunDipilih =
                                        int.tryParse(value ?? '') ??
                                        DateTime.now().year,
                                  );
                                  await _fetchStatistik();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _isLoadingChart
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            )
                          : SfCartesianChart(
                              plotAreaBorderWidth: 0,
                              primaryXAxis: CategoryAxis(
                                labelStyle: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              primaryYAxis: NumericAxis(
                                labelStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                axisLine: const AxisLine(width: 0),
                                majorGridLines: const MajorGridLines(
                                  color: Colors.grey,
                                  width: 0.3,
                                ),
                                interval: 1,
                              ),
                              tooltipBehavior: TooltipBehavior(enable: true),
                              series: <CartesianSeries<_GrafikData, String>>[
                                ColumnSeries<_GrafikData, String>(
                                  dataSource: chartData,
                                  xValueMapper: (data, _) => data.kategori,
                                  yValueMapper: (data, _) => data.jumlah,
                                  pointColorMapper: (data, _) => data.warna,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(2),
                                  ),
                                  width: 0.5,
                                  dataLabelSettings: const DataLabelSettings(
                                    isVisible: true,
                                    labelAlignment:
                                        ChartDataLabelAlignment.middle,
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),

                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.group,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Total Balita: $totalBalita",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Detail Grafik",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Table(
                            border: TableBorder.all(
                              color: Colors.grey.shade300,
                            ),
                            children: [
                              _buildRow([
                                "Status Gizi",
                                "Laki-laki",
                                "Perempuan",
                                "Total",
                              ], isHeader: true),
                              _buildRow([
                                "Normal",
                                "$_lakiNormal",
                                "$_perempuanNormal",
                                "$_normal",
                              ]),
                              _buildRow([
                                "Kurang",
                                "$_lakiKurang",
                                "$_perempuanKurang",
                                "$_kurang",
                              ]),
                              _buildRow([
                                "Obesitas",
                                "$_lakiObesitas",
                                "$_perempuanObesitas",
                                "$_obesitas",
                              ]),
                              _buildRow([
                                "Total",
                                "$_totalLaki",
                                "$_totalPerempuan",
                                "$total",
                              ], isHeader: true),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Ringkasan Pertumbuhan Balita - $_bulanDipilih",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Total balita: $total anak\n"
                            "• Laki-laki: $_totalLaki anak\n"
                            "• Perempuan: $_totalPerempuan anak\n\n"
                            "• Normal: $_normal anak\n"
                            "• Kurang gizi: $_kurang anak\n"
                            "• Obesitas: $_obesitas anak\n\n"
                            "${_getAnalisisGizi(_normal, _kurang, _obesitas, total)}",
                            style: const TextStyle(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: Column(
                  children: [
                    _isGeneratingPdf
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: _generateAndExportPdf,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(
                              Icons.picture_as_pdf,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Download Laporan Bulanan",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                    if (_isBulanKhusus) ...[
                      const SizedBox(height: 12),
                      _isGeneratingPdfKhusus
                          ? const CircularProgressIndicator()
                          : ElevatedButton.icon(
                              onPressed: () =>
                                  _generateAndExportPdf(isLaporanKhusus: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(
                                Icons.assignment,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Download Laporan Khusus",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                      const SizedBox(height: 8),
                      Text(
                        "* Laporan khusus untuk bulan $_bulanDipilih",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildRow(List<String> data, {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(color: isHeader ? Colors.grey.shade100 : null),
      children: data.map((text) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _GrafikData {
  final String kategori;
  final int jumlah;
  final Color warna;
  _GrafikData(this.kategori, this.jumlah, this.warna);
}
