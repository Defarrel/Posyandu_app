import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:posyandu_app/core/components/custom_texfield2.dart';
import 'package:posyandu_app/core/components/custom_dropdown_field.dart';
import 'package:posyandu_app/core/components/custom_textfield.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/models/request/perkembangan_balita/perkembangan_request_model.dart';
import 'package:posyandu_app/data/models/response/perkembangan_balita/perkembangan_balita_reponse.dart';
import 'package:posyandu_app/data/repository/perkembangan_balita_repository.dart';

class TambahPerkembanganBalita extends StatefulWidget {
  final String nikBalita;
  final String namaBalita;
  final PerkembanganBalitaResponseModel? existingData;

  const TambahPerkembanganBalita({
    super.key,
    required this.nikBalita,
    required this.namaBalita,
    this.existingData,
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

  DateTime _selectedDate = DateTime.now();
  String? _caraUkur = "Berdiri";
  String? _kms;
  String? _imd;
  String? _vitaminA;
  String? _asiEks;

  bool _formBerubah() {
    return _beratController.text.isNotEmpty ||
        _tinggiController.text.isNotEmpty ||
        _lingkarLenganController.text.isNotEmpty ||
        _lingkarKepalaController.text.isNotEmpty ||
        (_caraUkur != "Berdiri") ||
        (_kms != null) ||
        (_imd != null) ||
        (_asiEks != null) ||
        (_vitaminA != null);
  }

  bool _isLoading = false;
  final _repo = PerkembanganBalitaRepository();

  bool get isSpecialMonth {
    final month = _selectedDate.month;
    return month == 2 || month == 8;
  }

  @override
  void initState() {
    super.initState();

    if (widget.existingData != null) {
      final d = widget.existingData!;
      _beratController.text = d.beratBadan?.toString() ?? "";
      _tinggiController.text = d.tinggiBadan?.toString() ?? "";
      _lingkarLenganController.text = d.lingkarLengan?.toString() ?? "";
      _lingkarKepalaController.text = d.lingkarKepala?.toString() ?? "";
      _caraUkur = d.caraUkur ?? "Berdiri";
      _kms = d.kms;
      _imd = d.imd;
      _vitaminA = d.vitaminA;
      _asiEks = d.asiEks;
      _selectedDate =
          DateTime.tryParse(d.tanggalPerubahan ?? "") ?? DateTime.now();
    }

    _beratController.addListener(_hitungKMS);
    _tinggiController.addListener(_hitungKMS);
  }

  Future<bool> _konfirmasiKeluar() async {
    if (!_formBerubah()) return true;

    final keluar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Perubahan Belum Disimpan"),
        content: const Text(
          "Anda memiliki perubahan yang belum disimpan. Keluar tanpa menyimpan?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Keluar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    return keluar ?? false;
  }

  @override
  void dispose() {
    _beratController.removeListener(_hitungKMS);
    _tinggiController.removeListener(_hitungKMS);
    _beratController.dispose();
    _tinggiController.dispose();
    _lingkarLenganController.dispose();
    _lingkarKepalaController.dispose();
    super.dispose();
  }

  void _hitungKMS() {
    final berat = double.tryParse(_beratController.text) ?? 0.0;
    final tinggi = double.tryParse(_tinggiController.text) ?? 0.0;

    if (berat > 0 && tinggi > 0) {
      final tinggiMeter = tinggi / 100;
      final imt = berat / (tinggiMeter * tinggiMeter);

      String hasilKMS;
      if (imt < 13.0) {
        hasilKMS = "Merah";
      } else if (imt <= 17.0) {
        hasilKMS = "Hijau";
      } else {
        hasilKMS = "Kuning";
      }

      setState(() => _kms = hasilKMS);
    }
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
    if (_beratController.text.isEmpty ||
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
      final tanggalPerubahan = widget.existingData != null
          ? widget.existingData!.tanggalPerubahan.split('T').first
          : "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

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
        tanggalPerubahan: tanggalPerubahan,
      );

      if (widget.existingData == null) {
        final result = await _repo.tambahPerkembangan(model);
        result.fold(
          (error) => ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Gagal: $error"))),
          (message) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
            Navigator.pop(context, true);
          },
        );
      } else {
        final id = widget.existingData!.id;
        final result = await _repo.updatePerkembangan(id, model);
        result.fold(
          (error) => ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Gagal: $error"))),
          (message) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
            Navigator.pop(context, true);
          },
        );
      }
    } catch (e) {
      log("Exception form: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.existingData != null;

    return WillPopScope(
      onWillPop: () async {
        return await _konfirmasiKeluar();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
            onPressed: () async {
              if (await _konfirmasiKeluar()) {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            isUpdate
                ? "Perbarui Data Perkembangan"
                : "Tambah Data Perkembangan Balita",
            style: const TextStyle(
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
                isUpdate
                    ? "Perbarui data perkembangan ${widget.namaBalita}"
                    : "Halo, ${widget.namaBalita}! Gimana perkembangan kamu bulan ini?",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    locale: const Locale('id', 'ID'),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                child: AbsorbPointer(
                  child: CustomTextFieldBalita(
                    label: "Tanggal Perkembangan",
                    hint: "Pilih tanggal perkembangan",
                    controller: TextEditingController(
                      text:
                          "${_selectedDate.day} ${_bulanIndo(_selectedDate.month)} ${_selectedDate.year}",
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
                items: const ["Berdiri", "Terlentang"],
                onChanged: (val) => setState(() => _caraUkur = val),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CustomDropdownField2(
                      label: "KMS",
                      value: _kms,
                      items: const ["Merah", "Hijau", "Kuning"],
                      onChanged: (val) => setState(() => _kms = val),
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
                      iconColor: isSpecialMonth
                          ? AppColors.primary
                          : Colors.grey,
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
                      items: const ["Merah", "Biru"],
                      onChanged: (val) => setState(() => _vitaminA = val),
                      enabled: isSpecialMonth,
                      iconColor: isSpecialMonth
                          ? AppColors.primary
                          : Colors.grey,
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
                      iconColor: isSpecialMonth
                          ? AppColors.primary
                          : Colors.grey,
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
                    _isLoading
                        ? "Menyimpan..."
                        : (isUpdate ? "Perbarui Data" : "Simpan"),
                    style: const TextStyle(color: Colors.white),
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
