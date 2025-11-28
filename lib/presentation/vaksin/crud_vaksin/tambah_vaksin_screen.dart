import 'package:flutter/material.dart';
import 'package:posyandu_app/core/components/custom_snackbar.dart';
import 'package:posyandu_app/core/components/custom_textfield.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/models/request/vaksin/vaksin_master_request_model.dart';
import 'package:posyandu_app/data/models/response/vaksin/vaksin_master_response_model.dart';
import 'package:posyandu_app/data/repository/vaksin_master_repository.dart';

class TambahVaksinScreen extends StatefulWidget {
  final bool isEdit;
  final VaksinMasterResponseModel? model;

  const TambahVaksinScreen({super.key, this.isEdit = false, this.model});

  @override
  State<TambahVaksinScreen> createState() => _TambahVaksinScreenState();
}

class _TambahVaksinScreenState extends State<TambahVaksinScreen> {
  final _kodeController = TextEditingController();
  final _namaController = TextEditingController();
  final _usiaController = TextEditingController();
  final _ketController = TextEditingController();

  String? _kodeError;
  String? _namaError;
  String? _usiaError;

  bool _loading = false;

  final VaksinMasterRepository _repo = VaksinMasterRepository();

  @override
  void initState() {
    super.initState();

    if (widget.isEdit && widget.model != null) {
      final v = widget.model!;
      _kodeController.text = v.kode;
      _namaController.text = v.namaVaksin;
      _usiaController.text = v.usiaBulan.toString();
      _ketController.text = v.keterangan ?? "";
    }
  }

  void _submit() async {
    setState(() {
      _kodeError = _kodeController.text.isEmpty
          ? "Kode vaksin wajib diisi"
          : null;
      _namaError = _namaController.text.isEmpty
          ? "Nama vaksin wajib diisi"
          : null;
      _usiaError = _usiaController.text.isEmpty ? "Usia wajib diisi" : null;
    });

    if (_kodeError != null || _namaError != null || _usiaError != null) return;

    setState(() => _loading = true);

    final request = VaksinMasterRequestModel(
      kode: _kodeController.text,
      namaVaksin: _namaController.text,
      usiaBulan: int.parse(_usiaController.text),
      keterangan: _ketController.text,
    );

    if (widget.isEdit) {
      // UPDATE
      final res = await _repo.updateVaksin(widget.model!.id, request);

      res.fold(
        (err) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar.show(message: err, type: SnackBarType.error),
          );
          setState(() => _loading = false);
        },
        (msg) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar.show(message: msg, type: SnackBarType.success),
          );
          Navigator.pop(context, true);
        },
      );
    } else {
      final res = await _repo.createVaksin(request);

      res.fold(
        (err) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar.show(message: err, type: SnackBarType.error),
          );
          setState(() => _loading = false);
        },
        (msg) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar.show(message: msg, type: SnackBarType.success),
          );
          Navigator.pop(context, true);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.isEdit;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? "Edit Master Vaksin" : "Tambah Master Vaksin",
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isEdit
                  ? "Perbarui data vaksin sesuai kolom"
                  : "Isi data vaksin sesuai kolom",
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextFieldBalita(
              label: "Kode Vaksin",
              hint: "Misal: HB-0",
              controller: _kodeController,
              errorText: _kodeError,
            ),
            const SizedBox(height: 12),

            CustomTextFieldBalita(
              label: "Nama Vaksin",
              hint: "Misal: Hepatitis B",
              controller: _namaController,
              errorText: _namaError,
            ),
            const SizedBox(height: 12),

            CustomTextFieldBalita(
              label: "Usia (bulan)",
              hint: "Misal: 9",
              controller: _usiaController,
              keyboardType: TextInputType.number,
              errorText: _usiaError,
            ),
            const SizedBox(height: 12),

            CustomTextFieldBalita(
              label: "Keterangan",
              hint: "Opsional",
              controller: _ketController,
              maxLines: 2,
            ),

            const SizedBox(height: 30),

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
                _loading
                    ? "Menyimpan..."
                    : (isEdit ? "Perbarui Vaksin" : "Simpan Vaksin"),
                style: const TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
