import 'package:flutter/material.dart';
import 'package:posyandu_app/core/components/custom_snackbar.dart';
import 'package:posyandu_app/core/components/custom_textfield.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/models/request/vaksin/vaksin_request_model.dart';
import 'package:posyandu_app/data/models/response/balita/balita_response.dart';
import 'package:posyandu_app/data/models/response/vaksin/vaksin_respone_model.dart';
import 'package:posyandu_app/data/repository/vaksin_repository.dart';
import 'package:intl/intl.dart';

class TambahVaksinBalita extends StatefulWidget {
  final BalitaResponseModel balita;
  final VaksinRiwayatModel? vaksinData;
  final bool isEdit;

  const TambahVaksinBalita({
    super.key,
    required this.balita,
    this.vaksinData,
    this.isEdit = false,
  });

  @override
  State<TambahVaksinBalita> createState() => _TambahVaksinBalitaState();
}

class _TambahVaksinBalitaState extends State<TambahVaksinBalita> {
  final VaksinRepository _repo = VaksinRepository();

  final _batchNoController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _petugasController = TextEditingController();

  VaksinMasterModel? _selectedVaksin;
  DateTime? _selectedDate;
  List<VaksinMasterModel> _listVaksin = [];
  bool _loading = false;
  bool _loadingVaksin = true;

  String? _vaksinError;
  String? _tanggalError;

  List<VaksinRiwayatModel> _riwayatVaksin = [];

  DateTime _parseDateSafe(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return DateTime.now();
    }
    try {
      final DateTime parsed = DateTime.parse(dateStr).toLocal();

      return DateTime(parsed.year, parsed.month, parsed.day);
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadVaksinMaster();
    if (widget.isEdit && widget.vaksinData != null) {
      _populateFormData();
    }
    _loadRiwayatVaksin();
  }

  void _populateFormData() {
    final vaksinData = widget.vaksinData!;

    _batchNoController.text = vaksinData.batchNo ?? '';
    _lokasiController.text = vaksinData.lokasi ?? '';
    _petugasController.text = vaksinData.petugas ?? '';

    _selectedDate = _parseDateSafe(vaksinData.tanggal);
  }

  Future<void> _loadRiwayatVaksin() async {
    final result = await _repo.getVaksinBalita(widget.balita.nikBalita);
    result.fold(
      (error) {
        print("Gagal load riwayat vaksin: $error");
      },
      (data) {
        if (mounted) {
          setState(() {
            _riwayatVaksin = data.data ?? [];
          });
        }
      },
    );
  }

  Future<void> _loadVaksinMaster() async {
    setState(() => _loadingVaksin = true);

    final result = await _repo.getVaksinMaster();

    result.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(message: error, type: SnackBarType.error),
        );
        setState(() => _loadingVaksin = false);
      },
      (data) {
        setState(() {
          _listVaksin = data;
          _loadingVaksin = false;
          if (widget.isEdit && widget.vaksinData != null) {
            _setSelectedVaksin();
          }
        });
      },
    );
  }

  void _setSelectedVaksin() {
    if (widget.vaksinData != null) {
      final currentVaksin = _listVaksin.firstWhere(
        (vaksin) => vaksin.namaVaksin == widget.vaksinData!.namaVaksin,
        orElse: () => _listVaksin.first,
      );

      setState(() {
        _selectedVaksin = currentVaksin;
      });
    }
  }

  bool _isVaksinSudahDiberikan() {
    if (_selectedVaksin == null) return false;

    final vaksinSudahAda = _riwayatVaksin.any(
      (riwayat) => riwayat.vaksinId == _selectedVaksin!.id,
    );

    if (widget.isEdit && widget.vaksinData != null) {
      return vaksinSudahAda &&
          widget.vaksinData!.vaksinId != _selectedVaksin!.id;
    }

    return vaksinSudahAda;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _tanggalError = null;
      });
    }
  }

  void _submit() async {
    setState(() {
      _vaksinError = (!widget.isEdit && _selectedVaksin == null)
          ? "Pilih jenis vaksin"
          : null;

      _tanggalError = _selectedDate == null ? "Pilih tanggal vaksin" : null;
    });

    if (_vaksinError != null || _tanggalError != null) return;

    if (!widget.isEdit && _isVaksinSudahDiberikan()) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.show(
          message:
              "Vaksin ${_selectedVaksin!.namaVaksin} sudah pernah diberikan kepada ${widget.balita.namaBalita}",
          type: SnackBarType.error,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    final baseDate = _selectedDate!;
    final compensatedDate = baseDate.add(const Duration(hours: 12));
    final tanggalKirim = compensatedDate.toIso8601String();

    final request = VaksinRequestModel(
      nik_balita: widget.balita.nikBalita,
      vaksin_id: widget.isEdit
          ? (_selectedVaksin?.id ?? widget.vaksinData!.vaksinId)
          : _selectedVaksin!.id,
      tanggal: tanggalKirim,
      petugas: _petugasController.text.isEmpty ? null : _petugasController.text,
      batch_no: _batchNoController.text.isEmpty
          ? null
          : _batchNoController.text,
      lokasi: _lokasiController.text.isEmpty ? null : _lokasiController.text,
    );

    if (widget.isEdit && widget.vaksinData != null) {
      final result = await _repo.updateVaksin(widget.vaksinData!.id, request);

      result.fold(
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar.show(message: error, type: SnackBarType.error),
          );
          setState(() => _loading = false);
        },
        (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar.show(message: success, type: SnackBarType.success),
          );
          Navigator.pop(context, true);
        },
      );
    } else {
      final result = await _repo.tambahVaksin(request);

      result.fold(
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar.show(message: error, type: SnackBarType.error),
          );
          setState(() => _loading = false);
        },
        (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar.show(message: success, type: SnackBarType.success),
          );
          Navigator.pop(context, true);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.isEdit;
    final title = isEdit ? "Edit Vaksin Balita" : "Tambah Vaksin Balita";
    final subtitle = isEdit
        ? "Edit data vaksin untuk ${widget.balita.namaBalita}"
        : "Isi data vaksin untuk ${widget.balita.namaBalita}";
    final buttonText = _loading
        ? "Menyimpan..."
        : (isEdit ? "Update Vaksin" : "Simpan Vaksin");

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
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
      body: _loadingVaksin
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildFormSection(isEdit),
                  const SizedBox(height: 30),

                  if (!isEdit && _isVaksinSudahDiberikan())
                    _buildWarningDuplikasi(),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _loading ? null : _submit,
                    child: Text(
                      buttonText,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildWarningDuplikasi() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.accent.withOpacity(0.8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Vaksin Sudah Pernah Diberikan",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Vaksin ${_selectedVaksin?.namaVaksin ?? ''} sudah pernah diberikan kepada ${widget.balita.namaBalita}. Tekan simpan untuk tetap menambahkannya.",
                  style: TextStyle(
                    color: AppColors.accent.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(bool isEdit) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEdit ? "Edit Data Vaksinasi" : "Data Vaksinasi",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          if (isEdit && widget.vaksinData != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Vaksin: ${widget.vaksinData!.namaVaksin}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Jenis Vaksin *",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _vaksinError != null
                        ? Colors.red
                        : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<VaksinMasterModel>(
                  value: _selectedVaksin,
                  isExpanded: true,
                  underline: const SizedBox(),
                  hint: Text(
                    isEdit
                        ? "Vaksin saat ini: ${widget.vaksinData?.namaVaksin ?? ''}"
                        : "Pilih jenis vaksin",
                  ),
                  items: _listVaksin.map((VaksinMasterModel vaksin) {
                    final sudahDiberikan = _riwayatVaksin.any(
                      (riwayat) => riwayat.vaksinId == vaksin.id,
                    );

                    return DropdownMenuItem<VaksinMasterModel>(
                      value: vaksin,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  vaksin.namaVaksin,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: sudahDiberikan && !isEdit
                                        ? Colors.orange.shade700
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              if (sudahDiberikan && !isEdit)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.orange.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    "SUDAH DIBERIKAN",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            "Usia ${vaksin.usiaBulan} bulan - ${vaksin.kode}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (VaksinMasterModel? newValue) {
                    setState(() {
                      _selectedVaksin = newValue;
                      _vaksinError = null;
                    });
                  },
                ),
              ),
              if (_vaksinError != null) ...[
                const SizedBox(height: 4),
                Text(
                  _vaksinError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tanggal Vaksin *",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _tanggalError != null
                          ? Colors.red
                          : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: _tanggalError != null
                            ? Colors.red
                            : AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate != null
                            ? DateFormat('dd MMMM yyyy').format(_selectedDate!)
                            : "Pilih tanggal vaksin",
                        style: TextStyle(
                          color: _selectedDate != null
                              ? Colors.black87
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_tanggalError != null) ...[
                const SizedBox(height: 4),
                Text(
                  _tanggalError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          CustomTextFieldBalita(
            label: "Nomor Batch",
            hint: "Opsional",
            controller: _batchNoController,
          ),
          const SizedBox(height: 16),

          CustomTextFieldBalita(
            label: "Lokasi Vaksinasi",
            hint: "Opsional",
            controller: _lokasiController,
          ),
          const SizedBox(height: 16),

          CustomTextFieldBalita(
            label: "Nama Petugas",
            hint: "Opsional",
            controller: _petugasController,
          ),
        ],
      ),
    );
  }
}
