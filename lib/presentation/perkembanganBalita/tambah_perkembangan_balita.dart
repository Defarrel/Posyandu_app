import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:posyandu_app/core/components/custom_texfield2.dart';
import 'package:posyandu_app/core/components/custom_dropdown_field.dart';
import 'package:posyandu_app/core/components/custom_textfield.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/models/request/perkembangan_balita/perkembangan_request_model.dart';
import 'package:posyandu_app/data/repository/perkembangan_balita_repository.dart';

class TambahPerkembanganBalita extends StatefulWidget {
  final String nikBalita;
  final String namaBalita;

  const TambahPerkembanganBalita({
    super.key,
    required this.nikBalita,
    required this.namaBalita,
  });

  @override
  State<TambahPerkembanganBalita> createState() =>
      _TambahPerkembanganBalitaState();
}

class _TambahPerkembanganBalitaState extends State<TambahPerkembanganBalita> {
  final _beratController = TextEditingController();
  final _tinggiController = TextEditingController();
  final _lingkarLenganController = TextEditingController();
  final _lingkarKepalaController = TextEditingController();

  DateTime? _selectedDate;
  String? _caraUkur = "Berdiri";
  String? _kms;
  String? _imd;
  String? _vitaminA;
  String? _asiEks;

  bool _isLoading = false;

  bool get isSpecialMonth {
    if (_selectedDate == null) return false;
    final month = _selectedDate!.month;
    return month == 2 || month == 8;
  }

  String _bulanIndo(int month) {
    const bulan = [
      '',
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
    return bulan[month];
  }

  void _submitForm() async {
    if (_selectedDate == null ||
        _beratController.text.isEmpty ||
        _tinggiController.text.isEmpty ||
        _lingkarLenganController.text.isEmpty ||
        _lingkarKepalaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap isi semua data terlebih dahulu")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final model = PerkembanganBalitaRequestModel(
        nikBalita: widget.nikBalita,
        lingkarLengan: double.tryParse(_lingkarLenganController.text) ?? 0.0,
        lingkarKepala: double.tryParse(_lingkarKepalaController.text) ?? 0.0,
        tinggiBadan: double.tryParse(_tinggiController.text) ?? 0.0,
        beratBadan: double.tryParse(_beratController.text) ?? 0.0,
        caraUkur: _caraUkur ?? "-",
        vitaminA: _vitaminA ?? "-",
        kms: _kms ?? "-",
        imd: _imd ?? "-",
        asiEks: _asiEks ?? "-",
        tanggalPerubahan:
            "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
      );


      final repo = PerkembanganBalitaRepository();
      final result = await repo.tambahPerkembangan(model);

      result.fold(
        (error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Gagal: $error")));
        },
        (message) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          Navigator.pop(context);
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tambah Data Perkembangan Balita",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Halo, ${widget.namaBalita} gimana nih perkembangan kamu bulan ini?",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: () async {
                FocusScope.of(context).unfocus();
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              child: AbsorbPointer(
                child: CustomTextFieldBalita(
                  label: "Tanggal Perkembangan",
                  hint: "Pilih tanggal perkembangan",
                  controller: TextEditingController(
                    text: _selectedDate == null
                        ? ""
                        : "${_selectedDate!.day} ${_bulanIndo(_selectedDate!.month)} ${_selectedDate!.year}",
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField2(
                    label: "Berat Badan",
                    hint: "0 kg",
                    controller: _beratController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomTextField2(
                    label: "Tinggi Badan",
                    hint: "0 cm",
                    controller: _tinggiController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomTextField2(
                    label: "Lingkar Lengan",
                    hint: "0 cm",
                    controller: _lingkarLenganController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomTextField2(
                    label: "Lingkar Kepala",
                    hint: "0 cm",
                    controller: _lingkarKepalaController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            CustomDropdownField(
              label: "Cara Ukur",
              value: _caraUkur,
              items: const ["Berdiri", "Telentang"],
              onChanged: (val) => setState(() => _caraUkur = val),
            ),

            Row(
              children: [
                Expanded(
                  child: CustomDropdownField2(
                    label: "KMS",
                    value: _kms,
                    items: const ["Merah", "Hijau"],
                    onChanged: (val) => setState(() => _kms = val),
                    enabled: isSpecialMonth,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomDropdownField2(
                    label: "IMD",
                    value: _imd,
                    items: const ["Ya", "Tidak"],
                    onChanged: (val) => setState(() => _imd = val),
                    enabled: isSpecialMonth,
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: CustomDropdownField2(
                    label: "Vitamin A",
                    value: _vitaminA,
                    items: const ["Sudah", "Belum"],
                    onChanged: (val) => setState(() => _vitaminA = val),
                    enabled: isSpecialMonth,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomDropdownField2(
                    label: "ASI Eksklusif",
                    value: _asiEks,
                    items: const ["Ya", "Tidak"],
                    onChanged: (val) => setState(() => _asiEks = val),
                    enabled: isSpecialMonth,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  _isLoading ? "Menyimpan..." : "Simpan",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
