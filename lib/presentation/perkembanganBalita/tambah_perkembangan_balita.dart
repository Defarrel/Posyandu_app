import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:posyandu_app/core/components/custom_snackbar.dart';
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
  final String jenisKelamin;
  final DateTime tanggalLahir;
  final PerkembanganBalitaResponseModel? existingData;

  const TambahPerkembanganBalita({
    super.key,
    required this.nikBalita,
    required this.namaBalita,
    required this.jenisKelamin,
    required this.tanggalLahir,
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

  String? _errorBerat;
  String? _errorTinggi;
  String? _errorLengan;
  String? _errorKepala;
  String? _errorKMS;
  String? _errorIMD;
  String? _errorVitaminA;
  String? _errorAsiEks;

  DateTime _selectedDate = DateTime.now();
  String? _caraUkur = "Berdiri";
  String? _kms = "Ada";
  String? _imd;
  String? _vitaminA;
  String? _asiEks;

  bool _isLoading = false;
  bool _isInitLoading = true;

  final _repo = PerkembanganBalitaRepository();
  List<PerkembanganBalitaResponseModel> _existingHistory = [];

  bool _userPickedDate = false;

  DateTime _parseDateSafe(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return DateTime.now();
    try {
      final parsed = DateTime.parse(dateStr).toLocal();
      return DateTime(parsed.year, parsed.month, parsed.day);
    } catch (_) {
      return DateTime.now();
    }
  }

  bool _formBerubah() {
    return _beratController.text.isNotEmpty ||
        _tinggiController.text.isNotEmpty ||
        _lingkarLenganController.text.isNotEmpty ||
        _lingkarKepalaController.text.isNotEmpty ||
        _caraUkur != "Berdiri" ||
        _kms != "Ada" ||
        _imd != null ||
        _asiEks != null ||
        _vitaminA != null;
  }

  bool get isSpecialMonth =>
      _selectedDate.month == 2 || _selectedDate.month == 8;

  @override
  void initState() {
    super.initState();
    _loadRiwayat().then((_) {
      if (widget.existingData != null) {
        final d = widget.existingData!;
        _beratController.text = d.beratBadan?.toString() ?? "";
        _tinggiController.text = d.tinggiBadan?.toString() ?? "";
        _lingkarLenganController.text = d.lingkarLengan?.toString() ?? "";
        _lingkarKepalaController.text = d.lingkarKepala?.toString() ?? "";
        _caraUkur = d.caraUkur ?? "Berdiri";
        _kms = d.kms ?? "Ada";
        _imd = d.imd;
        _vitaminA = d.vitaminA;
        _asiEks = d.asiEks;

        _selectedDate = _parseDateSafe(d.tanggalPerubahan);
      } else {
        _selectedDate = DateTime.now();
      }
      if (mounted) setState(() => _isInitLoading = false);
    });
  }

  Future<void> _loadRiwayat() async {
    try {
      final result = await _repo.getPerkembanganByNIK(widget.nikBalita);
      result.fold(
        (error) => log("Gagal load history: $error"),
        (data) => _existingHistory = data,
      );
    } catch (e) {
      log("Error riwayat: $e");
    }
  }

  @override
  void dispose() {
    _beratController.dispose();
    _tinggiController.dispose();
    _lingkarLenganController.dispose();
    _lingkarKepalaController.dispose();
    super.dispose();
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

  String _bulanIndo(int month) {
    const bulan = [
      "",
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
    return bulan[month];
  }

  bool _validateInputs() {
    bool isValid = true;

    setState(() {
      _errorBerat = null;
      _errorTinggi = null;
      _errorLengan = null;
      _errorKepala = null;
      _errorKMS = null;
      _errorIMD = null;
      _errorVitaminA = null;
      _errorAsiEks = null;
    });

    if (_kms == null || _kms!.isEmpty) {
      _errorKMS = "Pilih status KMS";
      isValid = false;
    }

    if (isSpecialMonth) {
      if (_imd == null || _imd!.isEmpty) {
        _errorIMD = "Pilih status IMD";
        isValid = false;
      }
      if (_vitaminA == null || _vitaminA!.isEmpty) {
        _errorVitaminA = "Pilih Vitamin A";
        isValid = false;
      }
      if (_asiEks == null || _asiEks!.isEmpty) {
        _errorAsiEks = "Pilih status ASI Eksklusif";
        isValid = false;
      }
    }

    double? numParse(String t) => double.tryParse(t.replaceAll(",", "."));

    if (_beratController.text.isEmpty ||
        numParse(_beratController.text) == null ||
        numParse(_beratController.text)! <= 0 ||
        numParse(_beratController.text)! > 50) {
      _errorBerat = "Berat tidak valid";
      isValid = false;
    }

    if (_tinggiController.text.isEmpty ||
        numParse(_tinggiController.text) == null ||
        numParse(_tinggiController.text)! <= 0 ||
        numParse(_tinggiController.text)! > 150) {
      _errorTinggi = "Tinggi tidak valid";
      isValid = false;
    }

    if (_lingkarLenganController.text.isEmpty ||
        numParse(_lingkarLenganController.text) == null ||
        numParse(_lingkarLenganController.text)! <= 0 ||
        numParse(_lingkarLenganController.text)! > 40) {
      _errorLengan = "Lingkar Lengan tidak valid";
      isValid = false;
    }

    if (_lingkarKepalaController.text.isEmpty ||
        numParse(_lingkarKepalaController.text) == null ||
        numParse(_lingkarKepalaController.text)! <= 0 ||
        numParse(_lingkarKepalaController.text)! > 65) {
      _errorKepala = "Lingkar Kepala tidak valid";
      isValid = false;
    }

    setState(() {});
    return isValid;
  }

  void _submitForm() async {
    if (!_validateInputs()) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.show(
          message: "Mohon lengkapi data bertanda merah.",
          type: SnackBarType.error,
        ),
      );
      return;
    }

    if (_isInitLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.show(
          message: "Sedang memuat data, coba lagi sebentar.",
          type: SnackBarType.error,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final selected = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    if (selected.isAfter(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.show(
          message: "Tidak dapat input data masa depan.",
          type: SnackBarType.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tanggalPerubahan = _selectedDate
          .add(const Duration(hours: 12))
          .toIso8601String();

      final model = PerkembanganBalitaRequestModel(
        nikBalita: widget.nikBalita,
        lingkarLengan: double.parse(
          _lingkarLenganController.text.replaceAll(",", "."),
        ),
        lingkarKepala: double.parse(
          _lingkarKepalaController.text.replaceAll(",", "."),
        ),
        tinggiBadan: double.parse(_tinggiController.text.replaceAll(",", ".")),
        beratBadan: double.parse(_beratController.text.replaceAll(",", ".")),
        caraUkur: _caraUkur ?? "-",
        vitaminA: _vitaminA ?? "-",
        kms: _kms ?? "-",
        imd: _imd ?? "-",
        asiEks: _asiEks ?? "-",
        tanggalPerubahan: tanggalPerubahan,
      );

      late final result;

      if (widget.existingData == null) {
        result = await _repo.tambahPerkembangan(model);
      } else {
        result = await _repo.updatePerkembangan(widget.existingData!.id, model);
      }

      result.fold(
        (error) => ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(
            message: "Gagal: $error",
            type: SnackBarType.error,
          ),
        ),
        (msg) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar.show(message: msg, type: SnackBarType.success),
          );
          Navigator.pop(context, true);
        },
      );
    } catch (e) {
      log("Error submit: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.show(message: "Error: $e", type: SnackBarType.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.existingData != null;

    return WillPopScope(
      onWillPop: () async => await _konfirmasiKeluar(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
            onPressed: () async {
              if (await _konfirmasiKeluar()) Navigator.pop(context);
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isUpdate
                    ? "Perbarui Data Perkembangan"
                    : "Tambah Data Perkembangan",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isUpdate
                    ? "Perbarui data ${widget.namaBalita}"
                    : "Halo, ${widget.namaBalita}! Gimana perkembangannya?",
                style: const TextStyle(color: Colors.black54, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: _isInitLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: widget.tanggalLahir,
                          lastDate: DateTime(2100),
                          locale: const Locale("id", "ID"),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                            );
                            _userPickedDate = true;

                            if (!isSpecialMonth) {
                              _imd = null;
                              _vitaminA = null;
                              _asiEks = null;
                            }
                          });
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

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField2(
                            label: "Berat Badan",
                            hint: "4.8 kg",
                            controller: _beratController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            errorText: _errorBerat,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField2(
                            label: "Tinggi Badan",
                            hint: "49.3 cm",
                            controller: _tinggiController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            errorText: _errorTinggi,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField2(
                            label: "Lingkar Lengan",
                            hint: "18.6 cm",
                            controller: _lingkarLenganController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            errorText: _errorLengan,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField2(
                            label: "Lingkar Kepala",
                            hint: "45.1 cm",
                            controller: _lingkarKepalaController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            errorText: _errorKepala,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    CustomDropdownField(
                      label: "Cara Ukur",
                      value: _caraUkur,
                      items: const ["Berdiri", "Terlentang"],
                      onChanged: (val) => setState(() => _caraUkur = val),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: CustomDropdownField2(
                            label: "KMS",
                            value: _kms,
                            items: const ["Ada", "Tidak"],
                            onChanged: (val) => setState(() => _kms = val),
                            errorText: _errorKMS,
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
                            errorText: _errorIMD,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

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
                            errorText: _errorVitaminA,
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
                            errorText: _errorAsiEks,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

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
