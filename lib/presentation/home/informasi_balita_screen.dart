import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:posyandu_app/core/components/custom_snackbar.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/models/response/balita/balita_response.dart';
import 'package:posyandu_app/data/repository/perkembangan_balita_repository.dart';
import 'package:posyandu_app/presentation/balita/detail_balita_screen.dart';

class InformasiBalitaScreen extends StatefulWidget {
  const InformasiBalitaScreen({super.key});

  @override
  State<InformasiBalitaScreen> createState() => _InformasiBalitaScreenState();
}

class _InformasiBalitaScreenState extends State<InformasiBalitaScreen> {
  final PerkembanganBalitaRepository _repository =
      PerkembanganBalitaRepository();
  List<Map<String, dynamic>> _dataBalita = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final result = await _repository.getBalitaPerluPerhatian();

    if (!mounted) return;

    result.fold(
      (error) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(message: error, type: SnackBarType.error),
        );
      },
      (data) {
        setState(() {
          _dataBalita = data.map((e) => e.toMap()).toList();
          _isLoading = false;
        });
      },
    );
  }

  void _confirmAndNavigate(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary),
              const SizedBox(width: 10),
              const Text("Lihat Detail?"),
            ],
          ),
          content: Text.rich(
            TextSpan(
              text: "Apakah anda ingin melihat data lengkap \n",
              style: const TextStyle(color: Colors.black87),
              children: [
                TextSpan(
                  text: item['nama'] ?? "-",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const TextSpan(text: " ?"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Batal",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                try {
                  final safeMap = {
                    'nik_balita': item['nik']?.toString() ?? '',
                    'nama_balita': item['nama']?.toString() ?? '',
                    'jenis_kelamin':
                        '', 
                    'tanggal_lahir': '1900-01-01',
                    'anak_ke_berapa': '0',
                    'nomor_kk': '',
                    'nama_ortu': '',
                    'nik_ortu': '',
                    'nomor_telp_ortu': '',
                    'alamat': '',
                    'rt': '',
                    'rw': '',
                    'createdAt': '',
                    ...item, 
                    'nik_balita': item['nik']?.toString() ?? '',
                    'nama_balita':
                        item['nama']?.toString() ??
                        item['nama_balita']?.toString() ??
                        '',
                  };

                  final balitaModel = BalitaResponseModel.fromMap(safeMap);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailBalitaScreen(balita: balitaModel),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    CustomSnackBar.show(
                      message:
                          "Gagal memuat detail balita. Data tidak lengkap.",
                      type: SnackBarType.error,
                    ),
                  );
                }
              },
              child: const Text(
                "Ya, Lihat",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Informasi Balita",
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
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: _fetchData,
              color: AppColors.primary,
              child: _dataBalita.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _dataBalita.length,
                      itemBuilder: (context, index) {
                        return _buildItemCard(_dataBalita[index]);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.green.shade300,
              ),
              const SizedBox(height: 16),
              const Text(
                "Semua Balita Sehat!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Tidak ada balita yang memerlukan perhatian khusus\npada bulan ini.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final kms = (item["kms"] ?? "").toString().toLowerCase();
    Color statusColor;
    Color statusBgColor;

    if (kms.contains("merah")) {
      statusColor = Colors.red;
      statusBgColor = Colors.red.withOpacity(0.1);
    } else if (kms.contains("kuning")) {
      statusColor = Colors.orange;
      statusBgColor = Colors.orange.withOpacity(0.1);
    } else if (kms.contains("abu")) {
      statusColor = Colors.grey;
      statusBgColor = Colors.grey.withOpacity(0.1);
    } else {
      statusColor = Colors.green;
      statusBgColor = Colors.green.withOpacity(0.1);
    }

    return GestureDetector(
      onTap: () => _confirmAndNavigate(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 6, color: statusColor),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Container(
                      width: 45,
                      height: 45,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Center(child: _SimpleLottieDot(kms: kms)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item["nama"] ?? "-",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "NIK: ${item["nik"]}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    item["alasan"] ?? "-",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SimpleLottieDot extends StatelessWidget {
  final String kms;

  const _SimpleLottieDot({Key? key, required this.kms}) : super(key: key);

  String _getLottiePath() {
    final status = kms.toLowerCase();
    if (status.contains("merah")) return 'lib/core/assets/lottie/dot_red.json';
    if (status.contains("kuning")) {
      return 'lib/core/assets/lottie/dot_orange.json';
    }
    return 'lib/core/assets/lottie/dot_green.json';
  }

  Color _getColor() {
    final status = kms.toLowerCase();
    if (status.contains("merah")) return Colors.redAccent;
    if (status.contains("kuning")) {
      return const Color.fromARGB(255, 255, 171, 64);
    }
    if (status.contains("abu")) return Colors.grey;
    return const Color.fromARGB(255, 76, 175, 80);
  }

  @override
  Widget build(BuildContext context) {
    if (kms.toLowerCase().contains("abu")) {
      return Container(
        width: 14,
        height: 14,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Lottie.asset(_getLottiePath(), repeat: true, animate: true),
        ),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: _getColor(), shape: BoxShape.circle),
        ),
      ],
    );
  }
}
