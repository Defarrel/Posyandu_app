import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:posyandu_app/core/components/custom_dropdown_button.dart';
import 'package:posyandu_app/core/components/custom_snackbar.dart';
import 'package:posyandu_app/data/models/response/perkembangan_balita/perkembangan_item.dart';
import 'package:posyandu_app/data/models/response/perkembangan_balita/perkembangan_khusus_item.dart';
import 'package:posyandu_app/presentation/balita/list_gizi_balita_screen.dart';
import 'package:posyandu_app/services/laporan_bulanan.dart';
import 'package:posyandu_app/services/skdn_pdf_service.dart';
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
  String _persenS = "0";

  late String _bulanDipilih;
  late int _tahunDipilih;
  late List<int> _tahunList;

  bool _isLoadingChart = true;
  bool _isGeneratingPdf = false;
  bool _isGeneratingPdfKhusus = false;

  int _normal = 0;
  int _kurang = 0;
  int _lebih = 0;
  int _buruk = 0;
  int _obesitas = 0;

  int _lakiNormal = 0;
  int _lakiKurang = 0;
  int _lakiLebih = 0;
  int _lakiBuruk = 0;
  int _lakiObesitas = 0;

  int _perempuanNormal = 0;
  int _perempuanKurang = 0;
  int _perempuanLebih = 0;
  int _perempuanBuruk = 0;
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar.show(
              message: ("Gagal memuat data SKDN: $error"),
              type: SnackBarType.error,
            ),
          );
        }
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
          _persenS = data.persentase.nS;
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar.show(
              message: ("Gagal memuat data grafik: $error"),
              type: SnackBarType.error,
            ),
          );
        }
        setState(() => _isLoadingChart = false);
      },
      (data) {
        try {
          final laki = (data['laki_laki'] ?? {}) as Map<String, dynamic>;
          final perempuan = (data['perempuan'] ?? {}) as Map<String, dynamic>;

          setState(() {
            _normal = (data['normal'] ?? 0) as int;

            _buruk = (data['buruk'] ?? 0) as int;
            _kurang = (data['kurang'] ?? 0) as int;

            _lebih = (data['lebih'] ?? 0) as int;
            _obesitas = (data['obesitas'] ?? 0) as int;

            _totalLaki = (data['total_laki'] ?? 0) as int;
            _totalPerempuan = (data['total_perempuan'] ?? 0) as int;

            _lakiNormal = (laki['normal'] ?? 0) as int;
            _lakiBuruk = (laki['buruk'] ?? 0) as int;
            _lakiKurang = (laki['kurang'] ?? 0) as int;
            _lakiLebih = (laki['lebih'] ?? 0) as int;
            _lakiObesitas = (laki['obesitas'] ?? 0) as int;

            _perempuanNormal = (perempuan['normal'] ?? 0) as int;
            _perempuanBuruk = (perempuan['buruk'] ?? 0) as int;
            _perempuanKurang = (perempuan['kurang'] ?? 0) as int;
            _perempuanLebih = (perempuan['lebih'] ?? 0) as int;
            _perempuanObesitas = (perempuan['obesitas'] ?? 0) as int;

            _isLoadingChart = false;
          });
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              CustomSnackBar.show(
                message: ("Format data tidak sesuai: $e"),
                type: SnackBarType.error,
              ),
            );
          }
          setState(() => _isLoadingChart = false);
        }
      },
    );
  }

  bool get _isBulanKhusus {
    final bulanIndex = _bulanList.indexOf(_bulanDipilih) + 1;
    return bulanIndex == 2 || bulanIndex == 8;
  }

  Future<void> _downloadLaporanSKDN() async {
    setState(() => _isGeneratingPdf = true);
    try {
      final int targetMonthIndex = _bulanList.indexOf(_bulanDipilih) + 1;
      List<SkdnDataModel> listDataSKDN = [];

      for (int i = 1; i <= 12; i++) {
        if (i <= targetMonthIndex) {
          final result = await _repository.getSKDN(
            bulan: i,
            tahun: _tahunDipilih,
          );

          result.fold(
            (error) {
              listDataSKDN.add(
                SkdnDataModel(
                  bulan: _bulanList[i - 1].substring(0, 3).toUpperCase(),
                  s: 0,
                  k: 0,
                  d: 0,
                  n: 0,
                  jumlahLulus: 0,
                  jumlahS36: 0,
                ),
              );
              print("Warning: Gagal ambil data bulan ke-$i: $error");
            },
            (data) {
              listDataSKDN.add(
                SkdnDataModel(
                  bulan: _bulanList[i - 1].substring(0, 3).toUpperCase(),
                  s: data.s,
                  k: data.k,
                  d: data.d,
                  n: data.n,
                  jumlahLulus: data.jumlahLulus,
                  jumlahS36: data.jumlahS36,
                ),
              );
            },
          );
        } else {
          listDataSKDN.add(
            SkdnDataModel(
              bulan: _bulanList[i - 1].substring(0, 3).toUpperCase(),
              s: 0,
              k: 0,
              d: 0,
              n: 0,
              jumlahLulus: 0,
              jumlahS36: 0,
            ),
          );
        }
      }

      final pdfBytes = await LaporanSkdnService.generateSkdnPdf(
        data: listDataSKDN,
        namaPosyandu: "DAHLIA X",
        tahun: _tahunDipilih.toString(),
      );

      await LaporanSkdnService.saveAndShare(
        pdfBytes,
        "laporan_skdn_$_tahunDipilih.pdf",
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(
            message: "Laporan SKDN Tahun $_tahunDipilih berhasil diunduh",
            type: SnackBarType.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(
            message: "Gagal mengunduh laporan: $e",
            type: SnackBarType.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(
            message: ("Gagal generate PDF: $e"),
            type: SnackBarType.error,
          ),
        );
      }
    } finally {
      if (isLaporanKhusus) {
        setState(() => _isGeneratingPdfKhusus = false);
      } else {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  String _getAnalisisGizi(
    int normal,
    int kurang,
    int lebih,
    int obesitas,
    int buruk,
    int total,
  ) {
    if (total == 0) return "Belum ada data perkembangan bulan ini.";
    final totalMasalah = kurang + buruk + lebih + obesitas;
    final persenNormal = (normal / total) * 100;

    final totalKurangBuruk = kurang + buruk;

    if (totalMasalah == 0) {
      return "Semua balita berada pada kategori gizi normal. Bagus sekali!";
    }
    if (persenNormal >= 80 && totalKurangBuruk == 0) {
      return "Sebagian besar balita berada dalam batas normal. Perhatikan $lebih balita dengan risiko gizi lebih.";
    }
    if (totalKurangBuruk > 0 && totalKurangBuruk <= 5) {
      return "Ada $totalKurangBuruk balita yang mengalami gizi kurang/buruk. Perlu penanganan segera dan edukasi gizi.";
    }
    if (totalMasalah > 10) {
      return "Perlu intervensi! Proporsi gizi kurang, buruk, lebih, atau obesitas cukup tinggi (${totalMasalah} balita).";
    }
    return "Mayoritas balita normal, namun $totalMasalah balita perlu perhatian intensif.";
  }

  String _getAnalisisSKDN() {
    if (_s == 0) return "Belum ada data balita.";
    return "Data Bulan $_bulanDipilih:\n"
        "• Liputan (K/S): $_persenK%\n"
        "• Partisipasi (D/S): $_persenD%\n"
        "• Keberhasilan (N/D): $_persenN%\n"
        "• Pencapaian (N/S): $_persenS%";
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
        : (_normal + _kurang + _lebih + _obesitas + _buruk);

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
        _GrafikData('Lebih', _lebih, Colors.yellow.shade700),
        _GrafikData('Normal', _normal, Colors.green),
        _GrafikData('Kurang', _kurang, Colors.orangeAccent),
        _GrafikData('Buruk', _buruk, Colors.red),
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
                            : totalBalita == 0 &&
                                  _tipeGrafikDipilih == 'Status Gizi'
                            ? _buildEmptyDataMessage("Status Gizi")
                            : totalBalita == 0 && _tipeGrafikDipilih == 'SKDN'
                            ? _buildEmptyDataMessage("SKDN")
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
                                  decimalPlaces: 0,
                                  minimum: 0,
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
                      child: _isLoadingChart
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : (_tipeGrafikDipilih == 'Status Gizi'
                                ? _buildModernGiziLayout(totalBalita)
                                : _buildCleanSKDNLayout()),
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
                                        _lebih,
                                        _obesitas,
                                        _buruk,
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
                                    color: AppColors.accent,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.picture_as_pdf_sharp,
                                  color: AppColors.accent,
                                ),
                          label: Text(
                            _isGeneratingPdfKhusus
                                ? "Memproses..."
                                : "Download Laporan Khusus",
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isGeneratingPdf
                            ? null
                            : _downloadLaporanSKDN,
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
                              : "Download Laporan SKDN",
                          style: const TextStyle(
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

  Widget _buildEmptyDataMessage(String tipe) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.grey.shade400,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              "Tidak ada data $tipe",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              "Tidak ada balita yang diukur pada bulan ini atau datanya belum dimasukkan.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
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
    final summaryBadges = Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        _buildSummaryBadge("Total", "$total", Colors.blueGrey),
        _buildSummaryBadge("L", "$_totalLaki", Colors.blue),
        _buildSummaryBadge("P", "$_totalPerempuan", Colors.pink),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ringkasan Balita Aktif",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            summaryBadges,
          ],
        ),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SlideInAnimation(
              index: 0,
              child: _buildGiziDetailCard(
                index: 0,
                title: "Gizi Normal",
                sdInfo: ">= -2 SD s/d +2 SD",
                color: Colors.green,
                total: _normal,
                male: _lakiNormal,
                female: _perempuanNormal,
                icon: Icons.check_circle_outline,
              ),
            ),
            const SizedBox(height: 12),
            _SlideInAnimation(
              index: 1,
              child: _buildGiziDetailCard(
                index: 1,
                title: "Gizi Kurang",
                sdInfo: "< -2 SD s/d >= -3 SD",
                color: Colors.orangeAccent,
                total: _kurang,
                male: _lakiKurang,
                female: _perempuanKurang,
                icon: Icons.trending_down,
              ),
            ),
            const SizedBox(height: 12),
            _SlideInAnimation(
              index: 2,
              child: _buildGiziDetailCard(
                index: 2,
                title: "Gizi Buruk",
                sdInfo: "< -3 SD",
                color: Colors.red,
                total: _buruk,
                male: _lakiBuruk,
                female: _perempuanBuruk,
                icon: Icons.dangerous_outlined,
              ),
            ),
            const SizedBox(height: 12),
            _SlideInAnimation(
              index: 3,
              child: _buildGiziDetailCard(
                index: 3,
                title: "Risiko Gizi Lebih",
                sdInfo: "> +2 SD s/d +3 SD",
                color: Colors.yellow.shade700,
                total: _lebih,
                male: _lakiLebih,
                female: _perempuanLebih,
                icon: Icons.trending_up,
              ),
            ),
            const SizedBox(height: 12),
            _SlideInAnimation(
              index: 4,
              child: _buildGiziDetailCard(
                index: 4,
                title: "Obesitas",
                sdInfo: "> +3 SD",
                color: Colors.redAccent,
                total: _obesitas,
                male: _lakiObesitas,
                female: _perempuanObesitas,
                icon: Icons.sick_outlined,
              ),
            ),
          ],
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
        mainAxisSize: MainAxisSize.min,
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
    required int index,
    required String title,
    required String sdInfo,
    required Color color,
    required int total,
    required int male,
    required int female,
    required IconData icon,
  }) {
    final int delayStart = 600 + (index * 150);

    if (total == 0) {
      IconData emptyIcon;
      Color iconColor;
      String message;

      switch (title) {
        case "Gizi Buruk":
        case "Obesitas":
          emptyIcon = Icons.sentiment_very_satisfied;
          iconColor = Colors.blueGrey.shade500;
          message = "Tidak ada balita $title. Bagus!";
          break;
        case "Gizi Kurang":
        case "Risiko Gizi Lebih":
          emptyIcon = Icons.sentiment_very_satisfied;
          iconColor = Colors.blueGrey.shade500;
          message = "Tidak ada balita $title. Bagus";
          break;
        case "Gizi Normal":
        default:
          emptyIcon = Icons.sentiment_dissatisfied;
          iconColor = Colors.blueGrey.shade500;
          message = "Tidak ada balita $title bulan ini.";
          break;
      }

      return Container(
        padding: const EdgeInsets.all(16),
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(emptyIcon, color: iconColor, size: 24),
              const SizedBox(height: 4),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    double totalVal = total.toDouble();
    double malePct = totalVal > 0 ? male / totalVal : 0.0;
    double femalePct = totalVal > 0 ? female / totalVal : 0.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListGiziBalitaScreen(
                title: title,
                bulanNama: _bulanDipilih,
                bulanIndex: _bulanList.indexOf(_bulanDipilih) + 1,
                tahun: _tahunDipilih,
                themeColor: color,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, size: 18, color: color),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  "Ambang Batas: $sdInfo",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
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
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _AnimatedGenderBar(
                malePct: malePct,
                femalePct: femalePct,
                delayMs: delayStart,
              ),
              const SizedBox(height: 10),
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.male,
                            size: 14,
                            color: Colors.blue.shade400,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              "Laki-laki: $male (${(malePct * 100).toStringAsFixed(0)}%)",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    VerticalDivider(
                      width: 20,
                      thickness: 1,
                      indent: 2,
                      endIndent: 2,
                      color: Colors.grey.shade300,
                    ),
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              "Perempuan: $female (${(femalePct * 100).toStringAsFixed(0)}%)",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.female,
                            size: 14,
                            color: Colors.pink.shade400,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCleanSKDNLayout() {
    return Column(
      children: [
        _SlideInAnimation(
          index: 0,
          child: _buildCleanSKDNCard(
            index: 0,
            title: "Sasaran Balita (S)",
            count: _s,
            identityColor: Colors.red,
            formula: "Target N / S",
            percentageValue:
                (double.tryParse(
                      _persenS.replaceAll('%', '').replaceAll(',', '.'),
                    ) ??
                    0) /
                100,
            percentageText: "$_persenS%",
          ),
        ),
        const SizedBox(height: 12),
        _SlideInAnimation(
          index: 1,
          child: _buildCleanSKDNCard(
            index: 1,
            title: "Punya KMS (K)",
            count: _k,
            identityColor: Colors.yellow.shade800,
            formula: "Target: K / S",
            percentageValue:
                (double.tryParse(
                      _persenK.replaceAll('%', '').replaceAll(',', '.'),
                    ) ??
                    0) /
                100,
            percentageText: "$_persenK%",
          ),
        ),
        const SizedBox(height: 12),
        _SlideInAnimation(
          index: 2,
          child: _buildCleanSKDNCard(
            index: 2,
            title: "Datang Ditimbang (D)",
            count: _d,
            identityColor: Colors.green,
            formula: "Target: D / S",
            percentageValue:
                (double.tryParse(
                      _persenD.replaceAll('%', '').replaceAll(',', '.'),
                    ) ??
                    0) /
                100,
            percentageText: "$_persenD%",
          ),
        ),
        const SizedBox(height: 12),
        _SlideInAnimation(
          index: 3,
          child: _buildCleanSKDNCard(
            index: 3,
            title: "Naik Berat Badan (N)",
            count: _n,
            identityColor: Colors.blue,
            formula: "Target: N / D",
            percentageValue:
                (double.tryParse(
                      _persenN.replaceAll('%', '').replaceAll(',', '.'),
                    ) ??
                    0) /
                100,
            percentageText: "$_persenN%",
          ),
        ),
      ],
    );
  }

  Widget _buildCleanSKDNCard({
    required int index,
    required String title,
    required int count,
    required Color identityColor,
    String? formula,
    required double percentageValue,
    required String percentageText,
  }) {
    if (count == 0 && formula != null && _s > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: identityColor.withOpacity(0.6),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                "Tidak ada data $title bulan ini.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: identityColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final int delayStart = 600 + (index * 150);

    return _AnimatedSKDNCard(
      title: title,
      count: count,
      identityColor: identityColor,
      formula: formula,
      percentageValue: percentageValue,
      percentageText: percentageText,
      delayMs: delayStart,
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

class _SlideInAnimation extends StatefulWidget {
  final int index;
  final Widget child;
  const _SlideInAnimation({required this.index, required this.child});

  @override
  State<_SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<_SlideInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    Future.delayed(Duration(milliseconds: widget.index * 120), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _offsetAnimation, child: widget.child),
    );
  }
}

class _AnimatedGenderBar extends StatefulWidget {
  final double malePct;
  final double femalePct;
  final int delayMs;

  const _AnimatedGenderBar({
    required this.malePct,
    required this.femalePct,
    required this.delayMs,
  });

  @override
  State<_AnimatedGenderBar> createState() => _AnimatedGenderBarState();
}

class _AnimatedGenderBarState extends State<_AnimatedGenderBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void didUpdateWidget(_AnimatedGenderBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.malePct != widget.malePct ||
        oldWidget.femalePct != widget.femalePct) {
      _ctrl.reset();
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                Expanded(
                  flex: (widget.malePct * 100 * _anim.value).toInt(),
                  child: Container(color: Colors.blue.shade300),
                ),
                Expanded(
                  flex: widget.malePct == 1.0
                      ? 0
                      : (widget.femalePct * 100 * _anim.value).toInt(),
                  child: Container(color: Colors.pink.shade300),
                ),
                Expanded(
                  flex: (100 * (1.0 - _anim.value)).toInt(),
                  child: Container(color: Colors.transparent),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedSKDNCard extends StatefulWidget {
  final String title;
  final int count;
  final Color identityColor;
  final String? formula;
  final double percentageValue;
  final String percentageText;
  final int delayMs;

  const _AnimatedSKDNCard({
    required this.title,
    required this.count,
    required this.identityColor,
    this.formula,
    required this.percentageValue,
    required this.percentageText,
    required this.delayMs,
  });

  @override
  State<_AnimatedSKDNCard> createState() => _AnimatedSKDNCardState();
}

class _AnimatedSKDNCardState extends State<_AnimatedSKDNCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  late double _targetPercentage;

  @override
  void initState() {
    super.initState();
    _targetPercentage = widget.percentageValue;
    if (_targetPercentage > 1.0) _targetPercentage = 1.0;

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutExpo);

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void didUpdateWidget(_AnimatedSKDNCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentageValue != widget.percentageValue ||
        oldWidget.count != widget.count) {
      _targetPercentage = widget.percentageValue;
      if (_targetPercentage > 1.0) _targetPercentage = 1.0;

      _ctrl.reset();
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _getPerformanceColor(double percentage) {
    if (percentage >= 0.8) return Colors.green;
    if (percentage >= 0.5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final performanceColor = widget.formula == null
        ? widget.identityColor
        : _getPerformanceColor(widget.percentageValue);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: widget.identityColor.withOpacity(0.05),
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
                  widget.title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${widget.count} Data",
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
                    color: widget.identityColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          if (widget.formula != null) ...[
            AnimatedBuilder(
              animation: _anim,
              builder: (context, child) {
                final double currentVal = _targetPercentage * _anim.value;
                final String currentText =
                    "${(currentVal * 100).toStringAsFixed(1)}%";

                return Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currentText, 
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
                            widget.formula!,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
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
                            value: currentVal,
                            strokeWidth: 4,
                            backgroundColor: Colors.grey[100],
                            color: performanceColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
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
