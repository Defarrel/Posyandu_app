import 'package:flutter/material.dart';
import 'package:posyandu_app/core/components/custom_snackbar.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/models/request/kelulusan/kelulusan_request_model.dart';
import 'package:posyandu_app/data/models/response/kelulusan/kelulusan_response_model.dart';
import 'package:posyandu_app/data/repository/kelulusan_repository.dart';
import 'package:posyandu_app/services/certificate_service.dart';

class DetailKelulusanBalitaScreen extends StatefulWidget {
  final String nikBalita;
  final String namaBalita;

  const DetailKelulusanBalitaScreen({
    super.key,
    required this.nikBalita,
    required this.namaBalita,
  });

  @override
  State<DetailKelulusanBalitaScreen> createState() =>
      _DetailKelulusanBalitaScreenState();
}

class _DetailKelulusanBalitaScreenState
    extends State<DetailKelulusanBalitaScreen>
    with TickerProviderStateMixin {
  final KelulusanRepository _repo = KelulusanRepository();

  KelulusanDetailResponse? _data;
  bool _loading = true;
  bool _updating = false;
  bool _downloading = false;
  late AnimationController _animationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _buttonScaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _loading = true);
    final result = await _repo.getDetailKelulusan(widget.nikBalita);

    result.fold((error) => _showErrorSnackbar(error), (data) {
      setState(() {
        _data = data;
        _loading = false;
      });
      _animationController.forward();

      if (_data != null &&
          _data!.status != "LULUS" &&
          _data!.vaksin.progressVaksin >= 1.0 &&
          _data!.umur.progressUmur >= 1.0) {
        Future.delayed(Duration.zero, () {
          _setLulusManual(pesanKhusus: "Lulus otomatis (Syarat terpenuhi)");
        });
      }
    });
  }

  Future<void> _setLulusManual({String? pesanKhusus}) async {
    setState(() => _updating = true);

    final request = KelulusanRequestModel(
      status: "LULUS",
      keterangan: pesanKhusus ?? "Lulus manual oleh kader",
    );

    final result = await _repo.setKelulusan(widget.nikBalita, request);

    result.fold(
      (error) {
        _showErrorSnackbar(error);
        setState(() => _updating = false);
      },
      (message) {
        _showSuccessSnackbar(message);
        _loadDetail();
        setState(() => _updating = false);
      },
    );
  }

  Future<void> _setPindah() async {
    setState(() => _updating = true);

    final request = KelulusanRequestModel(
      status: "PINDAH",
      keterangan: "Pindah lokasi oleh kader",
    );

    final result = await _repo.setKelulusan(widget.nikBalita, request);

    result.fold(
      (error) {
        _showErrorSnackbar(error);
        setState(() => _updating = false);
      },
      (message) {
        _showSuccessSnackbar(message);
        _loadDetail();
        setState(() => _updating = false);
      },
    );
  }

  Future<void> _downloadSertifikat() async {
    setState(() => _downloading = true);
    _buttonAnimationController.forward();

    try {
      final file = await CertificateService.saveAndShare(
        namaBalita: widget.namaBalita,
      );

      _showSuccessSnackbar("Sertifikat berhasil diunduh dan dibagikan!");
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      setState(() => _downloading = false);
      _buttonAnimationController.reverse();
    }
  }

  void _showConfirmLulusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              "Konfirmasi Lulus",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Apakah Anda yakin ingin meluluskan balita ini secara manual?",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            if (_data != null && !_data!.siapLulus)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                ),
                child: const Text(
                  "Balita belum memenuhi syarat kelulusan otomatis. Tindakan ini akan meluluskan secara paksa.",
                  style: TextStyle(fontSize: 12, color: AppColors.accent),
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
            onPressed: () {
              Navigator.pop(context);
              _setLulusManual();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text("Ya, Luluskan"),
          ),
        ],
      ),
    );
  }

  void _showConfirmPindahDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.accent),
            SizedBox(width: 8),
            Text(
              "Konfirmasi Pindah",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Apakah Anda yakin ingin memindahkan balita ini?",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              "Status balita akan berubah menjadi 'PINDAH' dan tidak dapat diubah kembali.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _setPindah();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text("Ya, Pindahkan"),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackBar.show(message: message, type: SnackBarType.error),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackBar.show(message: message, type: SnackBarType.success),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Detail Kelulusan",
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
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _animationController,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - _animationController.value)),
                    child: child,
                  ),
                );
              },
              child: _buildContent(),
            ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProfileCard(),
          const SizedBox(height: 20),
          _buildProgressSection(),
          const SizedBox(height: 20),
          _buildStatusCard(),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.9),
            AppColors.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.child_care, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.namaBalita,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "NIK: ${(widget.nikBalita)}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _data!.status,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_data!.status == "LULUS")
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified, color: Colors.white, size: 28),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final vaksin = _data!.vaksin;
    final umur = _data!.umur;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.timeline, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                "Progress Kelulusan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildProgressItem(
            title: "Vaksinasi",
            value: vaksin.progressVaksin,
            current: vaksin.sudahDiambil,
            total: vaksin.totalVaksin,
            color: Colors.green,
            icon: Icons.medical_services,
            description: "Imunisasi lengkap",
          ),
          const SizedBox(height: 20),

          _buildProgressItem(
            title: "Usia",
            value: umur.progressUmur,
            current: umur.umurBulan,
            total: 60,
            color: Colors.blue,
            icon: Icons.cake,
            description: "Menuju 5 tahun",
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem({
    required String title,
    required double value,
    required int current,
    required int total,
    required Color color,
    required IconData icon,
    required String description,
  }) {
    final percentage = (value * 100).toInt();
    final isComplete = value >= 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isComplete
                    ? color.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isComplete
                      ? color.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Text(
                "$percentage%",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isComplete ? color : Colors.grey,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 12,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$current dari $total",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            Text(
              "${current}/$total",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    final statusColor = _getStatusColor(_data!.status);
    final statusIcon = _getStatusIcon(_data!.status);
    final statusDescription = _getStatusDescription(_data!.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, size: 24, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Status Kelulusan: ",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusBadgeIcon(_data!.status),
                      size: 16,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _data!.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            statusDescription,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_data!.status == "LULUS") {
      return _buildDownloadButton();
    } else if (_data!.status == "PINDAH") {
      return _buildPindahInfo();
    } else {
      return _buildActionButtonsRow();
    }
  }

  Widget _buildDownloadButton() {
    return AnimatedBuilder(
      animation: _buttonScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonScaleAnimation.value,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            shadowColor: AppColors.primary.withOpacity(0.4),
          ),
          onPressed: _downloading ? null : _downloadSertifikat,
          child: _downloading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download, size: 22),
                    SizedBox(width: 12),
                    Text(
                      "Download Sertifikat Kelulusan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildActionButtonsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: _updating ? null : _showConfirmLulusDialog,
              child: _updating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "Luluskan",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent),
                minimumSize: const Size(0, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _updating ? null : _showConfirmPindahDialog,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.move_to_inbox, size: 18),
                  SizedBox(width: 8),
                  Text("Pindah", style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPindahInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.accent, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Balita telah dipindahkan. Tidak ada tindakan yang dapat dilakukan.",
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "LULUS":
        return Colors.green;
      case "BELUM LULUS":
        return AppColors.accent;
      case "PINDAH":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getStatusIcon(String status) {
    switch (status) {
      case "LULUS":
        return Icons.check_circle;
      case "BELUM LULUS":
        return Icons.pending;
      case "PINDAH":
        return Icons.move_to_inbox;
      default:
        return Icons.help;
    }
  }

  IconData _getStatusBadgeIcon(String status) {
    switch (status) {
      case "LULUS":
        return Icons.verified;
      case "BELUM LULUS":
        return Icons.schedule;
      case "PINDAH":
        return Icons.location_on;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case "LULUS":
        return "Balita telah memenuhi semua syarat kelulusan dan dapat mengunduh sertifikat";
      case "BELUM LULUS":
        return "Balita belum memenuhi semua syarat kelulusan. Periksa progress di atas";
      case "PINDAH":
        return "Balita telah pindah ke lokasi posyandu lain";
      default:
        return "Status tidak diketahui";
    }
  }
}
