import 'package:flutter/material.dart';
import 'package:posyandu_app/core/components/custom_snackbar.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/models/request/vaksin/vaksin_request_model.dart';
import 'package:posyandu_app/data/models/response/balita/balita_response.dart';
import 'package:posyandu_app/data/models/response/vaksin/vaksin_respone_model.dart';
import 'package:posyandu_app/data/repository/auth_repository.dart';
import 'package:posyandu_app/data/repository/vaksin_repository.dart';
import 'package:intl/intl.dart';
import 'package:posyandu_app/presentation/vaksin/tambah_vaksin_balita.dart';
import 'package:posyandu_app/services/services_http_client.dart';

class VaksinDetailScreen extends StatefulWidget {
  final BalitaResponseModel balita;

  const VaksinDetailScreen({super.key, required this.balita});

  @override
  State<VaksinDetailScreen> createState() => _VaksinDetailScreenState();
}

class _VaksinDetailScreenState extends State<VaksinDetailScreen> {
  final VaksinRepository _vaksinRepo = VaksinRepository();
  final AuthRepository _authRepo = AuthRepository(ServiceHttpClient());

  VaksinDetailResponseModel? _vaksinData;
  VaksinRekomendasiResponseModel? _rekomendasiData;
  bool _loading = true;
  bool _loadingRekomendasi = false;
  bool _addingVaksin = false;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() => _loading = true);
    await Future.wait([_fetchVaksinData(), _fetchRekomendasiVaksin()]);
    setState(() => _loading = false);
  }

  Future<void> _fetchVaksinData() async {
    final result = await _vaksinRepo.getVaksinBalita(widget.balita.nikBalita);
    result.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(message: error, type: SnackBarType.error),
        );
      },
      (data) {
        setState(() {
          _vaksinData = data;
        });
      },
    );
  }

  Future<void> _fetchRekomendasiVaksin() async {
    setState(() => _loadingRekomendasi = true);
    final result = await _vaksinRepo.getRekomendasiVaksin(
      widget.balita.nikBalita,
    );
    result.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(message: error, type: SnackBarType.error),
        );
      },
      (data) {
        setState(() {
          _rekomendasiData = data;
        });
      },
    );
    setState(() => _loadingRekomendasi = false);
  }

  Future<void> _refreshData() async {
    await _fetchAllData();
  }

  int _hitungUmurBulan() {
    try {
      final lahir = DateFormat("yyyy-MM-dd").parse(widget.balita.tanggalLahir);
      final now = DateTime.now();
      return (now.difference(lahir).inDays / 30.4375).floor();
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final umur = _hitungUmurBulan();
    final bool showRekomendasi =
        _rekomendasiData?.vaksinSelanjutnya?.isNotEmpty ?? false;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Detail Vaksin",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TambahVaksinBalita(balita: widget.balita),
            ),
          ).then((refresh) {
            if (refresh == true) {
              _refreshData();
            }
          });
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: _refreshData,
              color: AppColors.primary,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoBalita(umur),
                          const SizedBox(height: 20),
                          _buildProgressSection(),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),

                  if (showRekomendasi)
                    SliverMainAxisGroup(
                      slivers: [
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _SectionHeaderDelegate(
                            child: _buildRekomendasiHeader(),
                            height: 60,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildRekomendasiContent(),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 10)),
                      ],
                    ),

                  SliverMainAxisGroup(
                    slivers: [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SectionHeaderDelegate(
                          child: _buildRiwayatHeader(),
                          height: 60,
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final riwayat = _vaksinData?.data ?? [];
                            if (riwayat.isEmpty) {
                              if (index == 0) {
                                return Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: _buildEmptyState(),
                                );
                              }
                              return null;
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: _buildRiwayatItem(riwayat[index]),
                            );
                          },
                          childCount: (_vaksinData?.data?.isEmpty ?? true)
                              ? 1
                              : _vaksinData!.data!.length,
                        ),
                      ),
                    ],
                  ),

                  // Spacer Bawah
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
    );
  }

  Widget _buildRekomendasiHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white, // Penting agar content di belakang tidak terlihat
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.recommend,
              color: AppColors.accent.withOpacity(0.8),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Rekomendasi Vaksin",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          if (_loadingRekomendasi)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildRiwayatHeader() {
    final riwayat = _vaksinData?.data ?? [];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white, // Penting agar content di belakang tidak terlihat
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.history,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Riwayat Vaksin",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            "${riwayat.length} item",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRekomendasiContent() {
    final rekomendasi = _rekomendasiData?.vaksinSelanjutnya ?? [];
    final usiaBulan = _rekomendasiData?.usiaBulan ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Berdasarkan usia $usiaBulan bulan, berikut vaksin yang direkomendasikan:",
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
        ...rekomendasi.take(3).map((vaksin) => _buildRekomendasiItem(vaksin)),
        if (rekomendasi.length > 3) ...[
          const SizedBox(height: 8),
          Text(
            "+ ${rekomendasi.length - 3} vaksin lainnya",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildInfoBalita(int umur) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.9),
                  AppColors.primary.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.child_care, size: 36, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.balita.namaBalita,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                _buildInfoItem(Icons.cake_outlined, "$umur bulan"),
                const SizedBox(height: 4),
                Text(
                  "Lahir: ${DateFormat('dd MMM yyyy').format(DateTime.parse(widget.balita.tanggalLahir))}",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 140),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final progress = _vaksinData?.progress ?? 0;
    final sudahDiambil = _vaksinData?.sudahDiambil ?? 0;
    final totalVaksin = _vaksinData?.totalVaksin ?? 0;
    final percentage = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Progress Vaksinasi",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$percentage%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.3),
            color: Colors.white,
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$sudahDiambil dari $totalVaksin vaksin",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                "${_vaksinData?.sudahDiambil ?? 0}/${_vaksinData?.totalVaksin ?? 0}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRekomendasiItem(VaksinMasterModel vaksin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.vaccines,
              color: AppColors.accent.withOpacity(0.8),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaksin.namaVaksin,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Usia ${vaksin.usiaBulan} bulan • ${vaksin.kode}",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (vaksin.keterangan != null &&
                    vaksin.keterangan!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    vaksin.keterangan!,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (_addingVaksin)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              onPressed: () => _showKonfirmasiTambahVaksin(vaksin),
              icon: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.accent.withOpacity(0.8),
                size: 16,
              ),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  void _showKonfirmasiTambahVaksin(VaksinMasterModel vaksin) async {
    String petugasInfo = "Petugas Posyandu";
    String lokasiInfo = "Posyandu Dahlia X";

    final userResult = await _authRepo.getUserProfile();
    userResult.fold((error) {}, (user) {
      if (user.username != null && user.username!.isNotEmpty) {
        petugasInfo = user.username!;
      }
    });

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.vaccines, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text("Tambah Vaksin"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Apakah Anda yakin ingin memberikan vaksin:",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.accent.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vaksin.namaVaksin,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Kode: ${vaksin.kode}",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  Text(
                    "Usia: ${vaksin.usiaBulan} bulan",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  Divider(color: Colors.grey.shade300, height: 1),
                  const SizedBox(height: 6),
                  Text(
                    "Petugas: $petugasInfo",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "Lokasi: $lokasiInfo",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "Tanggal: ${DateFormat('dd MMM yyyy').format(DateTime.now())}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Vaksin akan langsung ditambahkan ke riwayat ${widget.balita.namaBalita}",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _tambahVaksinDariRekomendasi(vaksin);
            },
            child: const Text(
              "Ya, Tambahkan",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _tambahVaksinDariRekomendasi(VaksinMasterModel vaksin) async {
    if (_addingVaksin) return;

    setState(() => _addingVaksin = true);

    try {
      final userResult = await _authRepo.getUserProfile();

      String petugas = "Petugas Posyandu";
      String lokasi = "Posyandu";

      userResult.fold(
        (error) {
          print("Gagal ambil data user: $error");
        },
        (user) {
          if (user.username != null && user.username!.isNotEmpty) {
            petugas = user.username!;
          } else {
            petugas = "Petugas Posyandu";
          }
        },
      );

      final request = VaksinRequestModel(
        nik_balita: widget.balita.nikBalita,
        vaksin_id: vaksin.id,
        tanggal: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        petugas: petugas,
        batch_no: null,
        lokasi: lokasi,
      );

      final result = await _vaksinRepo.tambahVaksin(request);

      result.fold(
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar.show(message: error, type: SnackBarType.error),
          );
        },
        (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar.show(
              message: "Vaksin ${vaksin.namaVaksin} berhasil ditambahkan",
              type: SnackBarType.success,
            ),
          );
          _refreshData();
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.show(
          message: "Terjadi kesalahan: $e",
          type: SnackBarType.error,
        ),
      );
    } finally {
      setState(() => _addingVaksin = false);
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.vaccines_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            "Belum Ada Riwayat Vaksin",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tambahkan vaksin pertama untuk ${widget.balita.namaBalita}",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatItem(VaksinRiwayatModel vaksin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vaksin.namaVaksin,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildDetailChip(
                                "Usia ${vaksin.usiaBulan} bln",
                                AppColors.primaryLight,
                                Colors.white,
                              ),
                              _buildDetailChip(
                                vaksin.kode,
                                Colors.grey.shade100,
                                Colors.grey.shade700,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                color: Colors.blue,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text('Hapus'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          _showDeleteDialog(vaksin.id);
                        } else if (value == 'edit') {
                          _navigateToEditVaksin(vaksin);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Diberikan: ${DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.parse(vaksin.tanggal))}",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                if (vaksin.catatan.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      vaksin.catatan,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEditVaksin(VaksinRiwayatModel vaksin) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahVaksinBalita(
          balita: widget.balita,
          vaksinData: vaksin,
          isEdit: true,
        ),
      ),
    ).then((refresh) {
      if (refresh == true) {
        _refreshData();
      }
    });
  }

  Widget _buildDetailChip(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showDeleteDialog(int vaksinId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text("Hapus Vaksin"),
          ],
        ),
        content: const Text(
          "Data vaksin yang sudah dihapus tidak dapat dikembalikan. Yakin ingin menghapus?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteVaksin(vaksinId);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVaksin(int id) async {
    final result = await _vaksinRepo.deleteVaksin(id);

    result.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(message: error, type: SnackBarType.error),
        );
      },
      (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(message: success, type: SnackBarType.success),
        );
        _refreshData();
      },
    );
  }
}

class _SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SectionHeaderDelegate({required this.child, required this.height});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      height: height,
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _SectionHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
