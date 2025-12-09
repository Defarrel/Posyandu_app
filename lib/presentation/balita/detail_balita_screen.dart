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

  Map<String, String> _getDeskripsiDanRekomendasi(
    String status,
    String indikator,
  ) {
    final clean = status
        .replaceAll("(Merah)", "")
        .replaceAll("(Kuning)", "")
        .trim();

    String deskripsi = "";
    String rekomendasi = "";

    if (indikator == "BB/U") {
      switch (clean) {
        case "Gizi Buruk":
          deskripsi =
              "Berat badan jauh di bawah standar usia. Kondisi ini menunjukkan kekurangan gizi berat dan berisiko komplikasi kesehatan jika tidak ditangani segera.";
          rekomendasi =
              "Segera rujuk ke fasilitas kesehatan. Tingkatkan asupan gizi padat energi dan protein setiap hari, pantau BB mingguan, dan evaluasi oleh tenaga kesehatan.";
          break;

        case "Gizi Kurang":
          deskripsi =
              "Berat badan sedikit di bawah standar dan menunjukkan kecenderungan kurang gizi. Jika tidak ditangani, anak berisiko stagnan atau turun lagi.";
          rekomendasi =
              "Tambahkan makanan tinggi protein hewani (telur, ikan, ayam), tingkatkan frekuensi makan, dan lakukan pemantauan ulang dalam 2–4 minggu.";
          break;

        case "Gizi Normal":
          deskripsi =
              "Berat badan berada dalam rentang normal untuk usia anak. Pertumbuhan sejauh ini sesuai standar WHO.";
          rekomendasi =
              "Pertahankan pola makan seimbang, jadwal makan teratur, dan lakukan penimbangan rutin setiap bulan.";
          break;

        case "Risiko Gizi Lebih":
          deskripsi =
              "Berat badan mulai melebihi batas normal untuk usia. Perlu dikonfirmasi dengan indikator BB/TB. Kondisi ini bisa menjadi risiko gizi berlebih atau tanda awal anak memiliki postur tubuh tinggi.";
          rekomendasi =
              "Atur porsi makan, kurangi makanan manis/berlemak, dan tingkatkan aktivitas fisik ringan setiap hari. Periksa hasil BB/TB untuk konfirmasi status gizi akut.";
          break;

        case "Obesitas":
          deskripsi =
              "Berat badan sudah berada jauh di atas standar usia. Jika indikator BB/TB menunjukkan 'Normal', ini mungkin karena anak memiliki postur tubuh tinggi besar. Namun, jika BB/TB juga Gizi Lebih/Obesitas, kondisi ini memerlukan perhatian dan tindakan segera.";
          rekomendasi =
              "Evaluasi pola makan, hindari makanan cepat saji, kurangi gula, dan tingkatkan aktivitas fisik teratur. **Wajib konfirmasi dengan hasil BB/TB.** Konsultasi ke tenaga kesehatan dianjurkan.";
          break;
      }
    } else if (indikator == "TB/U") {
      switch (clean) {
        case "Sangat Pendek":
          deskripsi =
              "Tinggi badan sangat rendah dibanding standar WHO. Ini mengindikasikan stunting berat yang sudah terjadi dalam jangka lama.";
          rekomendasi =
              "Segera evaluasi kondisi gizi dan riwayat kesehatan anak. Tingkatkan makanan sumber protein hewani, dan lakukan pemeriksaan ke fasilitas kesehatan.";
          break;

        case "Pendek":
          deskripsi =
              "Anak mengalami stunting ringan dan berada di bawah standar tinggi badan menurut usia.";
          rekomendasi =
              "Perbanyak makanan sumber protein hewani, susu, serta perbaiki pola tidur. Pantau tinggi badan setiap bulan.";
          break;

        case "Normal":
          deskripsi =
              "Tinggi badan sesuai standar usia dan tidak menunjukkan tanda stunting.";
          rekomendasi =
              "Pertahankan pola makan bergizi seimbang dan stimulasi fisik seperti merangkak, berjalan, atau bermain aktif.";
          break;

        case "Tinggi":
          deskripsi =
              "Tinggi badan di atas rata-rata anak seusianya (anak tinggi besar). Jika BB/TB anak 'Normal', ini bukan masalah dan menunjukkan potensi pertumbuhan yang baik.";
          rekomendasi =
              "Tidak ada tindakan khusus. Pastikan nutrisi tetap seimbang dan pantau pertumbuhan secara rutin, terutama menjaga BB/TB tetap Normal.";
          break;
      }
    } else if (indikator == "BB/TB") {
      switch (clean) {
        case "Sangat Kurus":
          deskripsi =
              "Berat badan sangat kurang dibanding tinggi badan. Ini merupakan tanda wasting berat dan perlu penanganan segera.";
          rekomendasi =
              "Berikan makanan tinggi energi dan protein beberapa kali sehari, tambah camilan sehat, dan segera konsultasikan ke tenaga kesehatan.";
          break;

        case "Kurus":
          deskripsi =
              "Berat badan kurang dibanding tinggi badan, menunjukkan wasting ringan.";
          rekomendasi =
              "Tingkatkan kualitas gizi harian, termasuk protein hewani dan lemak baik. Lakukan pemantauan ulang dalam 14–30 hari.";
          break;

        case "Normal":
          deskripsi =
              "Berat badan proporsional terhadap tinggi badan sesuai standar WHO. Ini adalah indikator status gizi akut yang paling akurat.";
          rekomendasi =
              "Pertahankan makan sehat dan pemantauan rutin. Tidak memerlukan intervensi khusus.";
          break;

        case "Risiko Gizi Lebih":
          deskripsi =
              "Berat badan mulai melebihi batas ideal untuk tinggi badan, menandakan awal kecenderungan gizi lebih.";
          rekomendasi =
              "Kurangi makanan manis/berlemak, perbanyak buah dan sayur, dan dorong anak bergerak aktif setiap hari.";
          break;

        case "Gizi Lebih":
          deskripsi =
              "Berat badan jelas berlebih dibanding tinggi badan. Jika dibiarkan, risiko obesitas meningkat.";
          rekomendasi =
              "Atur porsi makan, batasi cemilan tinggi gula/garam, dan tingkatkan aktivitas fisik. Konsultasi ke Posyandu dianjurkan.";
          break;

        case "Obesitas":
          deskripsi =
              "Berat badan sangat berlebih dibanding tinggi badan. Kondisi ini memerlukan pemantauan dan perubahan pola makan segera.";
          rekomendasi =
              "Kendalikan pola makan ketat, hindari makanan cepat saji dan minuman manis, tingkatkan aktivitas fisik, dan konsultasikan ke fasilitas kesehatan.";
          break;
      }
    }

    return {
      "deskripsi": deskripsi.isEmpty ? "Data belum mencukupi." : deskripsi,
      "rekomendasi": rekomendasi.isEmpty
          ? "Tidak ada rekomendasi khusus."
          : rekomendasi,
    };
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
                    _FadeSlideTransition(
                      index: 0,
                      child: _buildProfileHeader(),
                    ),
                    const SizedBox(height: 16),
                    _FadeSlideTransition(index: 1, child: _buildBiodataCard()),
                    const SizedBox(height: 24),
                    _FadeSlideTransition(index: 2, child: _buildChartSection()),
                    const SizedBox(height: 24),
                    _FadeSlideTransition(index: 3, child: _buildMonthFilter()),
                    const SizedBox(height: 16),
                    _FadeSlideTransition(
                      index: 4,
                      child: _buildGrowthStatsAndData(),
                    ),
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

  Widget _buildGrowthStatsAndData() {
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
                foregroundColor: Colors.white,
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

    DateTime tglLahir;
    try {
      tglLahir = DateTime.parse(_balitaData.tanggalLahir);
    } catch (_) {
      tglLahir = DateTime.now();
    }

    DateTime tglUkur;
    try {
      tglUkur = DateTime.parse(p.tanggalPerubahan);
    } catch (_) {
      tglUkur = DateTime.now();
    }

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
    final descBBU = _getDeskripsiDanRekomendasi(statusGiziBBU, "BB/U");

    String statusGiziTBU = getStatusTinggiUmur(
      p.tinggiBadan.toDouble(),
      _balitaData.jenisKelamin,
      umurSaatUkur,
    );
    Color warnaStatusTBU = getColorStatusGizi(statusGiziTBU);
    final descTBU = _getDeskripsiDanRekomendasi(statusGiziTBU, "TB/U");

    String statusGiziBBTB = getStatusBeratTinggi(
      p.beratBadan.toDouble(),
      p.tinggiBadan.toDouble(),
      _balitaData.jenisKelamin,
      umurSaatUkur,
    );
    Color warnaStatusBBTB = getColorStatusGizi(statusGiziBBTB);
    final descBBTB = _getDeskripsiDanRekomendasi(statusGiziBBTB, "BB/TB");

    String rekomendasiBB = getRekomendasiBerat(
      umurSaatUkur,
      _balitaData.jenisKelamin,
    );

    String rekomendasiTB = getRekomendasiTinggi(
      umurSaatUkur,
      _balitaData.jenisKelamin,
    );

    final String measurementDetailBBTB =
        "BB ${p.beratBadan.toStringAsFixed(1)} kg | TB ${p.tinggiBadan.toStringAsFixed(1)} cm";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: _handleDeletePerkembangan,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        _GiziIndicatorCardExpandable(
          title: "BB/U",
          subtitle: "Berat Badan menurut Usia",
          status: statusGiziBBU,
          value: p.beratBadan.toDouble(),
          unit: "kg",
          color: warnaStatusBBU,
          deskripsiRekomendasi: descBBU,
          measurementDetail: "",
        ),
        const SizedBox(height: 12),
        _GiziIndicatorCardExpandable(
          title: "TB/U",
          subtitle: "Tinggi Badan menurut Usia",
          status: statusGiziTBU,
          value: p.tinggiBadan.toDouble(),
          unit: "cm",
          color: warnaStatusTBU,
          deskripsiRekomendasi: descTBU,
          measurementDetail: "",
        ),
        const SizedBox(height: 12),
        _GiziIndicatorCardExpandable(
          title: "BB/TB",
          subtitle: "Berat Badan menurut Tinggi Badan",
          status: statusGiziBBTB,
          value: 0.0,
          unit: statusGiziBBTB,
          color: warnaStatusBBTB,
          deskripsiRekomendasi: descBBTB,
          isBBTB: true,
          measurementDetail: measurementDetailBBTB,
        ),
        const SizedBox(height: 24),

        const Text(
          "Hasil Pengukuran Bulan Ini:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
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

        const SizedBox(height: 24),

        _buildTargetRekomendasi(rekomendasiBB, rekomendasiTB),

        const SizedBox(height: 16),

        _buildAdditionalInfo(),
      ],
    );
  }

  Widget _buildInfoRowWithIcon(
    IconData icon,
    String header,
    String content,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                header,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(content, style: const TextStyle(fontSize: 13, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTargetRekomendasi(String rekomendasiBB, String rekomendasiTB) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Target Pertumbuhan Ideal (Sesuai Usia):",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.primary,
            ),
          ),
          const Divider(height: 20, color: AppColors.primary),
          Row(
            children: [
              const Icon(
                Icons.monitor_weight_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Berat Badan Ideal",
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                    Text(
                      rekomendasiBB,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.height, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tinggi Badan Ideal",
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                    Text(
                      rekomendasiTB,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
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
            "Catatan Kesehatan Tambahan",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
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

class _GiziIndicatorCardExpandable extends StatefulWidget {
  final String title;
  final String subtitle;
  final String status;
  final double value;
  final String unit;
  final Color color;
  final Map<String, String> deskripsiRekomendasi;
  final bool isBBTB;
  final String measurementDetail;

  const _GiziIndicatorCardExpandable({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.value,
    required this.unit,
    required this.color,
    required this.deskripsiRekomendasi,
    this.isBBTB = false,
    required this.measurementDetail,
  });

  @override
  State<_GiziIndicatorCardExpandable> createState() =>
      _GiziIndicatorCardExpandableState();
}

class _GiziIndicatorCardExpandableState
    extends State<_GiziIndicatorCardExpandable>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _iconAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Widget _buildGiziHeader(String cleanStatus) {
    Widget valueDisplay;
    if (widget.isBBTB) {
      valueDisplay = Text(
        cleanStatus,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: widget.color.withOpacity(0.9),
        ),
      );
    } else {
      valueDisplay = RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: widget.value.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: widget.color.withOpacity(0.9),
              ),
            ),
            TextSpan(
              text: " ${widget.unit.split('(').first.trim()}",
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isExpanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "(${widget.subtitle})",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),

              const SizedBox(height: 4),
              valueDisplay,
            ],
          ),
        ),

        Row(
          children: [
            if (!widget.isBBTB)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.color.withOpacity(0.5),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  cleanStatus,
                  style: TextStyle(
                    color: widget.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            if (!widget.isBBTB) const SizedBox(width: 8),
            RotationTransition(
              turns: _iconAnimation,
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGiziExpandedContent() {
    return Column(
      key: const ValueKey('expanded_content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 20),
        if (widget.isBBTB)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              "Pengukuran: ${widget.measurementDetail}",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        _buildInfoRowWithIcon(
          Icons.info_outline,
          "Kesimpulan:",
          widget.deskripsiRekomendasi['deskripsi']!,
          Colors.black54,
        ),
        const SizedBox(height: 12),
        _buildInfoRowWithIcon(
          Icons.lightbulb_outline,
          "Rekomendasi:",
          widget.deskripsiRekomendasi['rekomendasi']!,
          AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildInfoRowWithIcon(
    IconData icon,
    String header,
    String content,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                header,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(content, style: const TextStyle(fontSize: 13, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String cleanStatus = widget.status
        .replaceAll('(Merah)', '')
        .replaceAll('(Kuning)', '')
        .trim();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGiziHeader(cleanStatus),

              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        final isEntering =
                            child.key == const ValueKey('expanded_content');

                        final slideTween = isEntering
                            ? Tween<Offset>(
                                begin: const Offset(0.0, -0.1),
                                end: Offset.zero,
                              )
                            : Tween<Offset>(
                                begin: Offset.zero,
                                end: const Offset(0.0, -0.1),
                              );

                        final slideAnimation = slideTween.animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        );

                        return ClipRect(
                          child: SlideTransition(
                            position: slideAnimation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          ),
                        );
                      },
                  child: _isExpanded
                      ? _buildGiziExpandedContent()
                      : const SizedBox.shrink(
                          key: ValueKey('collapsed_content'),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FadeSlideTransition extends StatefulWidget {
  final Widget child;
  final int index;

  const _FadeSlideTransition({required this.child, required this.index});

  @override
  _FadeSlideTransitionState createState() => _FadeSlideTransitionState();
}

class _FadeSlideTransitionState extends State<_FadeSlideTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    Future.delayed(Duration(milliseconds: widget.index * 150), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final slideOffset = Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).evaluate(_animation);

        return Opacity(
          opacity: _animation.value,
          child: Transform.translate(
            offset: slideOffset * 30,
            child: widget.child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
