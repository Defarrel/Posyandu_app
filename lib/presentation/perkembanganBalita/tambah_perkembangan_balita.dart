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
    if (dateStr == null || dateStr.isEmpty) {
      return DateTime.now();
    }

    try {
      final DateTime parsed = DateTime.parse(dateStr).toLocal();
      return DateTime(parsed.year, parsed.month, parsed.day);
    } catch (e) {
      log("Gagal parsing tanggal aman (Update Fix): $e, string: $dateStr");
      return DateTime.now();
    }
  }

  bool _formBerubah() {
    return _beratController.text.isNotEmpty ||
        _tinggiController.text.isNotEmpty ||
        _lingkarLenganController.text.isNotEmpty ||
        _lingkarKepalaController.text.isNotEmpty ||
        (_caraUkur != "Berdiri") ||
        (_kms != "Ada") ||
        (_imd != null) ||
        (_asiEks != null) ||
        (_vitaminA != null);
  }

  bool get isSpecialMonth {
    final month = _selectedDate.month;
    return month == 2 || month == 8;
  }

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
        _kms = (d.kms == "Ada" || d.kms == "Tidak") ? d.kms : "Ada";
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
        (error) {
          log("Gagal load history: $error");
        },
        (data) {
          if (mounted) {
            _existingHistory = data;
          } else {
            _existingHistory = data;
          }
        },
      );
    } catch (e) {
      log("Repository method mungkin belum ada atau error: $e");
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

  bool _validateInputs() {
    bool isValid = true;

    setState(() {
      _errorBerat = null;
      _errorTinggi = null;
      _errorLengan = null;
      _errorKepala = null;
    });

    double? parseNum(String t) => double.tryParse(t.replaceAll(',', '.'));

    if (_beratController.text.isEmpty ||
        parseNum(_beratController.text) == null ||
        parseNum(_beratController.text)! <= 0 ||
        parseNum(_beratController.text)! > 50) {
      _errorBerat = "Berat tidak valid";
      isValid = false;
    }

    if (_tinggiController.text.isEmpty ||
        parseNum(_tinggiController.text) == null ||
        parseNum(_tinggiController.text)! <= 0 ||
        parseNum(_tinggiController.text)! > 150) {
      _errorTinggi = "Tinggi tidak valid";
      isValid = false;
    }

    if (_lingkarLenganController.text.isEmpty ||
        parseNum(_lingkarLenganController.text) == null ||
        parseNum(_lingkarLenganController.text)! <= 0 ||
        parseNum(_lingkarLenganController.text)! > 40) {
      _errorLengan = "Lingkar Lengan tidak valid";
      isValid = false;
    }

    if (_lingkarKepalaController.text.isEmpty ||
        parseNum(_lingkarKepalaController.text) == null ||
        parseNum(_lingkarKepalaController.text)! <= 0 ||
        parseNum(_lingkarKepalaController.text)! > 65) {
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

    DateTime selectedMonthToCheck;
    if (widget.existingData != null && !_userPickedDate) {
      selectedMonthToCheck = _parseDateSafe(
        widget.existingData!.tanggalPerubahan,
      );
    } else {
      selectedMonthToCheck = selected;
    }

    bool isDuplicate = false;
    for (var item in _existingHistory) {
      final itemDate = _parseDateSafe(item.tanggalPerubahan);
      if (itemDate.year == selectedMonthToCheck.year &&
          itemDate.month == selectedMonthToCheck.month) {
        if (widget.existingData != null && widget.existingData!.id == item.id) {
          continue; 
        }
        isDuplicate = true;
        break;
      }
    }

    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.show(
          message:
              "Data bulan ${_bulanIndo(selectedMonthToCheck.month)} ${selectedMonthToCheck.year} sudah ada.",
          type: SnackBarType.error,
        ),
      );
      return;
    }

    if (selected.isAfter(today) &&
        !(widget.existingData != null && !_userPickedDate)) {
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
      final baseDate = _selectedDate;

      final compensatedDate = baseDate.add(const Duration(hours: 12));

      final tanggalPerubahan = compensatedDate.toIso8601String();

      final model = PerkembanganBalitaRequestModel(
        nikBalita: widget.nikBalita,
        lingkarLengan: double.parse(
          _lingkarLenganController.text.replaceAll(',', '.'),
        ),
        lingkarKepala: double.parse(
          _lingkarKepalaController.text.replaceAll(',', '.'),
        ),
        tinggiBadan: double.parse(_tinggiController.text.replaceAll(',', '.')),
        beratBadan: double.parse(_beratController.text.replaceAll(',', '.')),
        caraUkur: _caraUkur ?? "-",
        vitaminA: _vitaminA ?? "-",
        kms: _kms ?? "Tidak",
        imd: _imd ?? "-",
        asiEks: _asiEks ?? "-",
        tanggalPerubahan: tanggalPerubahan,
      );

      if (widget.existingData == null) {
        final result = await _repo.tambahPerkembangan(model);

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
      } else {
        final id = widget.existingData!.id;
        final result = await _repo.updatePerkembangan(id, model);

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
      }
    } catch (e) {
      log("Exception in _submitForm: $e");
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
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.primary,
              size: 20,
            ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
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
                          locale: const Locale('id', 'ID'),
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

                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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

                    const SizedBox(height: 10),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            items: const ["Ada", "Tidak"],
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
