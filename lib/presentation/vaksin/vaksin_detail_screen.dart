import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/models/response/balita/balita_response.dart';
import 'package:posyandu_app/data/models/response/vaksin/vaksin_respone_model.dart';
import 'package:posyandu_app/data/repository/vaksin_repository.dart';

class VaksinDetailScreen extends StatefulWidget {
  final BalitaResponseModel balita;

  const VaksinDetailScreen({super.key, required this.balita});

  @override
  State<VaksinDetailScreen> createState() => _VaksinDetailScreenState();
}

class _VaksinDetailScreenState extends State<VaksinDetailScreen> {
  final VaksinRepository _repo = VaksinRepository();

  bool _loading = true;

  List<VaksinRiwayatModel> _riwayat = [];
  List<VaksinMasterModel> _master = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final result1 = await _repo.getVaksinMaster();
    final result2 = await _repo.getRiwayatVaksin(widget.balita.nikBalita);

    result1.fold((err) => print(err), (data) => _master = data);
    result2.fold((err) => print(err), (data) => _riwayat = data);

    setState(() => _loading = false);
  }

  int _umurBulan() {
    final lahir = DateFormat("yyyy-MM-dd").parse(widget.balita.tanggalLahir);
    return ((DateTime.now().difference(lahir).inDays) / 30.4).floor();
  }

  @override
  Widget build(BuildContext context) {
    final balita = widget.balita;

    final sudah = _riwayat;

    final belum = _master.where((m) {
      return !sudah.any((r) => r.vaksinId == m.id);
    }).toList();

    final double progress = _master.isEmpty
        ? 0
        : (sudah.length / _master.length);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Detail Vaksin",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: const Icon(
                        Icons.child_care,
                        size: 36,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            balita.namaBalita,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "NIK: ${balita.nikBalita}",
                            style: const TextStyle(color: Colors.black54),
                          ),
                          Text(
                            "${_umurBulan()} bulan",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                const Text(
                  "Progress Vaksin",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),

                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 14,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${sudah.length} dari ${_master.length} vaksin selesai",
                  style: const TextStyle(color: Colors.black54),
                ),

                const SizedBox(height: 30),

                const Text(
                  "Sudah Diambil",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),

                if (sudah.isEmpty)
                  const Text(
                    "Belum ada riwayat vaksin",
                    style: TextStyle(color: Colors.black54),
                  )
                else
                  ...sudah.map((v) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 26,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  v.namaVaksin,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  "Tanggal: ${v.tanggalPemberian}",
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                Text(
                                  "Catatan: ${v.catatan}",
                                  style: const TextStyle(color: Colors.black45),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                const SizedBox(height: 20),

                const Text(
                  "Belum Diambil",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),

                if (belum.isEmpty)
                  const Text(
                    "Semua vaksin sudah lengkap 🎉",
                    style: TextStyle(color: Colors.black54),
                  )
                else
                  ...belum.map((v) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error,
                            color: Colors.redAccent,
                            size: 26,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  v.namaVaksin,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  "Usia rekomendasi: ${v.usiaBulan} bulan",
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                const SizedBox(height: 30),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    // TODO: buka form tambah vaksin
                  },
                  child: const Text(
                    "Tambah Catatan Vaksin",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
    );
  }
}
