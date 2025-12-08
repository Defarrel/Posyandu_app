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
    setState(() {
      _namaError = _namaController.text.isEmpty ? "Nama wajib diisi" : null;

      _ttlError = _selectedDate == null ? "Tanggal lahir wajib diisi" : null;

      _nikBalitaError = _nikBalitaController.text.isEmpty
          ? "NIK wajib diisi"
          : _nikBalitaController.text.length != 16
          ? "NIK harus 16 digit"
          : null;

      _jenisKelaminError = _jenisKelamin == null ? "Pilih jenis kelamin" : null;

      _anakKeError = _anakKeController.text.isEmpty
          ? "Anak ke wajib diisi"
          : null;

      _nomorKkError = _nomorKkController.text.isEmpty
          ? "Nomor KK wajib diisi"
          : _nomorKkController.text.length != 16
          ? "KK harus 16 digit"
          : null;

      _namaOrtuError = _namaOrtuController.text.isEmpty
          ? "Nama orang tua wajib diisi"
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

      _alamatError = _alamatController.text.isEmpty
          ? "Alamat wajib diisi"
          : null;

      final bbVal = double.tryParse(
        _bbLahirController.text.replaceAll(',', '.'),
      );
      _bbLahirError = _bbLahirController.text.isEmpty
          ? "BB lahir wajib diisi"
          : (bbVal == null || bbVal < 1 || bbVal > 6)
          ? "BB lahir harus 1 - 6 kg"
          : null;

      final tbVal = double.tryParse(
        _tbLahirController.text.replaceAll(',', '.'),
      );
      _tbLahirError = _tbLahirController.text.isEmpty
          ? "TB lahir wajib diisi"
          : (tbVal == null || tbVal < 30 || tbVal > 60)
          ? "TB lahir harus 30 - 60 cm"
          : null;

      _rtError = _rtController.text.isEmpty ? "RT wajib diisi" : null;
      _rwError = _rwController.text.isEmpty ? "RW wajib diisi" : null;
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
              onTap: widget.isEdit
                  ? null
                  : () async {
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
              child: Opacity(
                opacity: widget.isEdit ? 0.5 : 1,
                child: CustomTextFieldBalita(
                  label: "Tanggal Lahir",
                  hint: "Pilih tanggal lahir",
                  controller: _ttlController,
                  ignorePointer: true,
                  errorText: _ttlError,
                ),
              ),
            ),

            const SizedBox(height: 12),

            IgnorePointer(
              ignoring: widget.isEdit,
              child: Opacity(
                opacity: widget.isEdit ? 0.5 : 1,
                child: CustomTextFieldBalita(
                  label: "NIK Balita",
                  hint: "Masukkan NIK balita",
                  controller: _nikBalitaController,
                  keyboardType: TextInputType.number,
                  errorText: _nikBalitaError,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Opacity(
              opacity: widget.isEdit ? 0.5 : 1,
              child: CustomRadioBalita(
                groupValue: _jenisKelamin,
                onChanged: widget.isEdit
                    ? null
                    : (value) {
                        setState(() {
                          _jenisKelamin = value;
                          _jenisKelaminError = null;
                        });
                      },
              ),
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
              label: "Berat Badan Lahir (kg)",
              hint: "Contoh: 3.2",
              controller: _bbLahirController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              errorText: _bbLahirError,
            ),

            const SizedBox(height: 12),
            CustomTextFieldBalita(
              label: "Tinggi Badan Lahir (cm)",
              hint: "Contoh: 49.5",
              controller: _tbLahirController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              errorText: _tbLahirError,
            ),
            const SizedBox(height: 12),
            CustomTextFieldBalita(
              label: "Nomor KK",
              controller: _nomorKkController,
              keyboardType: TextInputType.number,
              errorText: _nomorKkError,
              hint: "Masukkan nomor KK",
            ),
            const SizedBox(height: 12),
            CustomTextFieldBalita(
              label: "Nama Orang Tua",
              controller: _namaOrtuController,
              errorText: _namaOrtuError,
              hint: "Masukkan nama orang tua",
            ),
            const SizedBox(height: 12),
            CustomTextFieldBalita(
              label: "NIK Ortu",
              controller: _nikOrtuController,
              keyboardType: TextInputType.number,
              errorText: _nikOrtuError,
              hint: "Masukkan NIK orang tua",
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
