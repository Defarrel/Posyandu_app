import 'package:flutter/material.dart';
import 'package:posyandu_app/core/components/custom_radio_button.dart';
import 'package:posyandu_app/core/components/custom_snackbar.dart';
import 'package:posyandu_app/core/components/custom_texfield2.dart';
import 'package:posyandu_app/core/components/custom_textfield.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/models/request/balita/balita_request_model.dart';
import 'package:posyandu_app/data/models/response/balita/balita_response.dart';
import 'package:posyandu_app/data/repository/balita_repository.dart';
import 'package:posyandu_app/presentation/perkembanganBalita/tambah_perkembangan_balita.dart';

class TambahBalitaScreen extends StatefulWidget {
  final bool isEdit;
  final BalitaResponseModel? data;

  const TambahBalitaScreen({super.key, this.isEdit = false, this.data});

  @override
  State<TambahBalitaScreen> createState() => _TambahBalitaScreenState();
}

class _TambahBalitaScreenState extends State<TambahBalitaScreen> {
  String? _jenisKelamin;
  DateTime? _selectedDate;

  final _namaController = TextEditingController();
  final _ttlController = TextEditingController();
  final _nikBalitaController = TextEditingController();
  final _anakKeController = TextEditingController();
  final _nomorKkController = TextEditingController();
  final _namaOrtuController = TextEditingController();
  final _nikOrtuController = TextEditingController();
  final _noTelpController = TextEditingController();
  final _alamatController = TextEditingController();
  final _rtController = TextEditingController();
  final _rwController = TextEditingController();
  final _bbLahirController = TextEditingController();
  final _tbLahirController = TextEditingController();

  bool _isLoading = false;

  String? _namaError;
  String? _ttlError;
  String? _nikBalitaError;
  String? _anakKeError;
  String? _nomorKkError;
  String? _namaOrtuError;
  String? _nikOrtuError;
  String? _noTelpError;
  String? _alamatError;
  String? _rtError;
  String? _rwError;
  String? _jenisKelaminError;
  String? _bbLahirError;
  String? _tbLahirError;

  final BalitaRepository _repository = BalitaRepository();

  @override
  void initState() {
    super.initState();

    if (widget.isEdit && widget.data != null) {
      final b = widget.data!;

      _namaController.text = b.namaBalita;
      _nikBalitaController.text = b.nikBalita;
      final jk = b.jenisKelamin.toLowerCase().replaceAll(" ", "");

      if (jk == "lakilaki" || jk == "l") {
        _jenisKelamin = "Laki-laki";
      } else {
        _jenisKelamin = "Perempuan";
      }

      _selectedDate = DateTime.tryParse(b.tanggalLahir);
      if (_selectedDate != null) {
        _ttlController.text =
            "${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}";
      }

      _anakKeController.text = b.anakKeBerapa;
      _nomorKkController.text = b.nomorKk;
      _namaOrtuController.text = b.namaOrtu;
      _nikOrtuController.text = b.nikOrtu;
      _noTelpController.text = b.nomorTelpOrtu;
      _alamatController.text = b.alamat;
      _rtController.text = b.rt;
      _rwController.text = b.rw;
      _bbLahirController.text = b.bbLahir;
      _tbLahirController.text = b.tbLahir;
    }
  }

  void _submitForm() async {
    final namaRegex = RegExp(r'^[a-zA-Z\s]+$');
    final alamatRegex = RegExp(r'^[a-zA-Z0-9\s\.,\/-]+$');

    setState(() {
      _namaError = _namaController.text.isEmpty
          ? "Nama wajib diisi"
          : !namaRegex.hasMatch(_namaController.text.trim())
          ? "Nama hanya boleh huruf dan spasi"
          : null;

      _ttlError = _selectedDate == null ? "Tanggal lahir wajib diisi" : null;

      _nikBalitaError = _nikBalitaController.text.isEmpty
          ? "NIK wajib diisi"
          : _nikBalitaController.text.length != 16
          ? "NIK harus 16 digit"
          : null;

      _jenisKelaminError = _jenisKelamin == null ? "Pilih jenis kelamin" : null;

      final anakText = _anakKeController.text.trim();
      final anakKeVal = int.tryParse(anakText);

      _anakKeError = anakText.isEmpty
          ? "Anak ke wajib diisi"
          : anakText.contains(RegExp(r'[^0-9]'))
          ? "Anak ke hanya boleh angka"
          : (anakKeVal == null)
          ? "Anak ke tidak valid"
          : (anakKeVal <= 0)
          ? "Anak ke tidak boleh 0 atau minus"
          : (anakText.length > 2)
          ? "Anak ke tidak boleh lebih dari 2 digit"
          : null;

      _nomorKkError = _nomorKkController.text.isEmpty
          ? "Nomor KK wajib diisi"
          : _nomorKkController.text.length != 16
          ? "KK harus 16 digit"
          : null;

      _namaOrtuError = _namaOrtuController.text.isEmpty
          ? "Nama orang tua wajib diisi"
          : !namaRegex.hasMatch(_namaOrtuController.text.trim())
          ? "Nama orang tua hanya boleh huruf dan spasi"
          : null;

      _nikOrtuError = _nikOrtuController.text.isEmpty
          ? "NIK orang tua wajib diisi"
          : _nikOrtuController.text.length != 16
          ? "NIK harus 16 digit"
          : null;

      _noTelpError = _noTelpController.text.isEmpty
          ? "Nomor telepon wajib diisi"
          : (_noTelpController.text.length < 11 ||
                _noTelpController.text.length > 13)
          ? "Nomor telepon harus 11 - 13 digit"
          : null;

      final alamat = _alamatController.text.trim();
      _alamatError = alamat.isEmpty
          ? "Alamat wajib diisi"
          : !alamatRegex.hasMatch(alamat)
          ? "Alamat hanya boleh huruf, angka, spasi, . , / dan -"
          : null;

      final bbText = _bbLahirController.text.trim();
      final bbVal = double.tryParse(bbText.replaceAll(',', '.'));

      _bbLahirError = bbText.isEmpty
          ? null 
          : (bbVal == null || bbVal < 1 || bbVal > 6)
          ? "BB lahir harus 1 - 6 kg"
          : null;

      final tbText = _tbLahirController.text.trim();
      final tbVal = double.tryParse(tbText.replaceAll(',', '.'));

      _tbLahirError = tbText.isEmpty
          ? null
          : (tbVal == null || tbVal < 30 || tbVal > 60)
          ? "TB lahir harus 30 - 60 cm"
          : null;

      final rtText = _rtController.text.trim();
      final rtVal = int.tryParse(rtText);

      _rtError = rtText.isEmpty
          ? "RT wajib diisi"
          : rtText.contains(RegExp(r'[^0-9]'))
          ? "RT hanya boleh angka"
          : (rtVal == null)
          ? "RT tidak valid"
          : (rtVal <= 0)
          ? "RT tidak boleh 0 atau minus"
          : (rtText.length > 3)
          ? "RT tidak boleh lebih dari 3 digit"
          : null;

      final rwText = _rwController.text.trim();
      final rwVal = int.tryParse(rwText);

      _rwError = rwText.isEmpty
          ? "RW wajib diisi"
          : rwText.contains(RegExp(r'[^0-9]'))
          ? "RW hanya boleh angka"
          : (rwVal == null)
          ? "RW tidak valid"
          : (rwVal <= 0)
          ? "RW tidak boleh 0 atau minus"
          : (rwText.length > 3)
          ? "RW tidak boleh lebih dari 3 digit"
          : null;
    });

    if (_namaError != null ||
        _ttlError != null ||
        _nikBalitaError != null ||
        _jenisKelaminError != null ||
        _anakKeError != null ||
        _nomorKkError != null ||
        _namaOrtuError != null ||
        _nikOrtuError != null ||
        _noTelpError != null ||
        _alamatError != null ||
        _rtError != null ||
        _rwError != null ||
        _bbLahirError != null ||
        _tbLahirError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.show(
          message: "Mohon lengkapi data yang bertanda merah",
          type: SnackBarType.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final balita = BalitaRequestModel(
      nikBalita: _nikBalitaController.text,
      namaBalita: _namaController.text,
      jenisKelamin: _jenisKelamin!,
      tanggalLahir:
          "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
      anakKeBerapa: _anakKeController.text,
      nomorKk: _nomorKkController.text,
      namaOrtu: _namaOrtuController.text,
      nikOrtu: _nikOrtuController.text,
      nomorTelpOrtu: _noTelpController.text,
      alamat: _alamatController.text,
      bbLahir: _bbLahirController.text,
      tbLahir: _tbLahirController.text,
      rt: _rtController.text,
      rw: _rwController.text,
    );

    if (widget.isEdit) {
      final result = await _repository.updateBalita(balita.nikBalita, balita);

      result.fold(
        (err) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar.show(
              message: ("Gagal: $err"),
              type: SnackBarType.error,
            ),
          );
          setState(() => _isLoading = false);
        },
        (msg) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar.show(message: (msg), type: SnackBarType.success),
          );
          Navigator.of(context).pop(true);
        },
      );
      return;
    }

    final result = await _repository.tambahBalita(balita);

    result.fold(
      (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(
            message: ("Gagal: $err"),
            type: SnackBarType.error,
          ),
        );
        setState(() => _isLoading = false);
      },
      (msg) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(message: (msg), type: SnackBarType.success),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TambahPerkembanganBalita(
              nikBalita: balita.nikBalita,
              namaBalita: balita.namaBalita,
              jenisKelamin: balita.jenisKelamin,
              tanggalLahir: DateTime.parse(balita.tanggalLahir),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEdit
        ? "Perbarui Data Balita"
        : "Tambah Data Balita Baru";

    final subtitle = widget.isEdit
        ? "Perbarui data sesuai kebutuhan"
        : "Silahkan lengkapi data sesuai kolom";

    final buttonText = widget.isEdit ? "Perbarui Data" : "Selanjutnya";

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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextFieldBalita(
              label: "Nama Balita",
              hint: "Masukkan nama lengkap",
              controller: _namaController,
              errorText: _namaError,
            ),
            const SizedBox(height: 12),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                FocusScope.of(context).unfocus();
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );

                if (pickedDate != null) {
                  _selectedDate = pickedDate;
                  _ttlController.text =
                      "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                  setState(() => _ttlError = null);
                }
              },
              child: CustomTextFieldBalita(
                label: "Tanggal Lahir",
                hint: "Pilih tanggal lahir",
                controller: _ttlController,
                ignorePointer: true,
                errorText: _ttlError,
              ),
            ),

            const SizedBox(height: 12),

            IgnorePointer(
              ignoring: false,
              child: DigitCounterTextField(
                label: "NIK Balita",
                hint: "Masukkan NIK balita",
                controller: _nikBalitaController,
                errorText: _nikBalitaError,
              ),
            ),

            const SizedBox(height: 12),

            CustomRadioBalita(
              groupValue: _jenisKelamin,
              onChanged: (value) {
                setState(() {
                  _jenisKelamin = value;
                  _jenisKelaminError = null;
                });
              },
            ),

            if (_jenisKelaminError != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    _jenisKelaminError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ),

            const SizedBox(height: 12),
            CustomTextFieldBalita(
              label: "Anak ke",
              hint: "Masukkan urutan anak",
              controller: _anakKeController,
              keyboardType: TextInputType.number,
              errorText: _anakKeError,
            ),
            const SizedBox(height: 12),
            CustomTextFieldBalita(
              label: "BB Lahir (kg)",
              hint: "Contoh: 3.2 (opsional)",
              controller: _bbLahirController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              errorText: _bbLahirError,
            ),

            const SizedBox(height: 12),
            CustomTextFieldBalita(
              label: "TB Lahir (cm)",
              hint: "Contoh: 49.5 (opsional)",
              controller: _tbLahirController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              errorText: _tbLahirError,
            ),
            const SizedBox(height: 12),
            DigitCounterTextField(
              label: "Nomor KK",
              hint: "Masukkan nomor KK",
              controller: _nomorKkController,
              errorText: _nomorKkError,
            ),
            const SizedBox(height: 12),
            CustomTextFieldBalita(
              label: "Nama Orang Tua",
              controller: _namaOrtuController,
              errorText: _namaOrtuError,
              hint: "Masukkan nama orang tua",
            ),
            const SizedBox(height: 12),
            DigitCounterTextField(
              label: "NIK Ortu",
              hint: "Masukkan NIK orang tua",
              controller: _nikOrtuController,
              errorText: _nikOrtuError,
            ),
            const SizedBox(height: 12),
            CustomTextFieldBalita(
              label: "No Telepon",
              controller: _noTelpController,
              keyboardType: TextInputType.phone,
              errorText: _noTelpError,
              hint: "Masukkan no telepon",
            ),
            const SizedBox(height: 12),
            CustomTextFieldBalita(
              label: "Alamat",
              controller: _alamatController,
              maxLines: 2,
              errorText: _alamatError,
              hint: "Masukkan alamat",
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField2(
                    label: "RT",
                    controller: _rtController,
                    keyboardType: TextInputType.number,
                    errorText: _rtError,
                    hint: "RT",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField2(
                    label: "RW",
                    controller: _rwController,
                    keyboardType: TextInputType.number,
                    errorText: _rwError,
                    hint: "RW",
                  ),
                ),
              ],
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
              onPressed: _isLoading ? null : _submitForm,
              child: Text(
                _isLoading ? "Menyimpan..." : buttonText,
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

class DigitCounterTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? errorText;

  const DigitCounterTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        CustomTextFieldBalita(
          label: label,
          hint: hint,
          controller: controller,
          keyboardType: TextInputType.number,
          errorText: errorText,
        ),

        Positioned(
          right: 12,
          bottom: 14,
          child: ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, _) {
              return Text(
                "${controller.text.length}/16",
                style: TextStyle(
                  color: controller.text.length == 16
                      ? Colors.green.withOpacity(0.8)
                      : Colors.red.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
