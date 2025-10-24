import 'package:flutter/material.dart';
import 'package:posyandu_app/core/components/custom_radio_button.dart';
import 'package:posyandu_app/core/components/custom_texfield2.dart';
import 'package:posyandu_app/core/components/custom_textfield.dart';
import 'package:posyandu_app/core/constant/constants.dart';
import 'package:posyandu_app/data/models/request/balita/balita_request_model.dart';
import 'package:posyandu_app/data/repository/balita_repository.dart';
import 'package:posyandu_app/presentation/home/home_root.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:posyandu_app/presentation/perkembanganBalita/tambah_perkembangan_balita.dart';

class TambahBalitaScreen extends StatefulWidget {
  const TambahBalitaScreen({Key? key}) : super(key: key);

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

  final BalitaRepository _repository = BalitaRepository();

  void _submitForm() async {
    setState(() {
      _namaError = _namaController.text.isEmpty
          ? "Nama balita wajib diisi"
          : null;
      _ttlError = _selectedDate == null ? "Tanggal lahir wajib diisi" : null;
      _nikBalitaError = _nikBalitaController.text.isEmpty
          ? "NIK wajib diisi"
          : _nikBalitaController.text.length != 16
          ? "NIK harus 16 digit"
          : null;
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
          : null;
      _alamatError = _alamatController.text.isEmpty
          ? "Alamat wajib diisi"
          : null;
      _rtError = _rtController.text.isEmpty ? "RT wajib diisi" : null;
      _rwError = _rwController.text.isEmpty ? "RW wajib diisi" : null;
      _jenisKelaminError = _jenisKelamin == null ? "Pilih jenis kelamin" : null;
    });
    if (_namaError != null ||
        _ttlError != null ||
        _nikBalitaError != null ||
        _anakKeError != null ||
        _nomorKkError != null ||
        _namaOrtuError != null ||
        _nikOrtuError != null ||
        _noTelpError != null ||
        _alamatError != null ||
        _rtError != null ||
        _rwError != null ||
        _jenisKelaminError != null)
      return;

    setState(() => _isLoading = true);

    final balita = BalitaRequestModel(
      nikBalita: _nikBalitaController.text,
      namaBalita: _namaController.text,
      jenisKelamin: _jenisKelamin!,
      tanggalLahir:
          "${_selectedDate!.year.toString().padLeft(4, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}", // YYYY-MM-DD
      anakKeBerapa: _anakKeController.text,
      nomorKk: _nomorKkController.text,
      namaOrtu: _namaOrtuController.text,
      nikOrtu: _nikOrtuController.text,
      nomorTelpOrtu: _noTelpController.text,
      alamat: _alamatController.text,
      rt: _rtController.text,
      rw: _rwController.text,
    );

    Either<String, String> result = await _repository.tambahBalita(balita);

    result.fold(
      (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: $error')));
      },
      (message) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                TambahPerkembanganBalita(nikBalita: _nikBalitaController.text),
          ),
        );
      },
    );

    setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tambah Data Balita Baru",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Silahkan lengkapi data sesuai dengan kolom",
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.primary,
            size: 18,
          ),
          onPressed: () => HomeRoot.navigateToTab(context, 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextFieldBalita(
              label: "Nama Balita",
              hint: "Masukkan nama lengkap balita",
              controller: _namaController,
              errorText: _namaError,
            ),
            const SizedBox(height: 12),
            // TTL pakai DatePicker
            GestureDetector(
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
                      "${pickedDate.day} ${_bulanIndo(pickedDate.month)} ${pickedDate.year}";
                  setState(() => _ttlError = null);
                }
              },
              child: AbsorbPointer(
                child: CustomTextFieldBalita(
                  label: "Tanggal Lahir",
                  hint: "Pilih tanggal lahir",
                  controller: _ttlController,
                  errorText: _ttlError,
                ),
              ),
            ),
            const SizedBox(height: 12),
            CustomTextFieldBalita(
              label: "NIK Balita",
              hint: "Masukkan NIK balita",
              controller: _nikBalitaController,
              keyboardType: TextInputType.number,
              errorText: _nikBalitaError,
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4),
                    child: Text(
                      _jenisKelaminError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
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
              label: "Nomor KK",
              hint: "Masukkan nomor KK",
              controller: _nomorKkController,
              keyboardType: TextInputType.number,
              errorText: _nomorKkError,
            ),
            const SizedBox(height: 12),
            CustomTextFieldBalita(
              label: "Nama Ortu",
              hint: "Masukkan nama orang tua",
              controller: _namaOrtuController,
              errorText: _namaOrtuError,
            ),
            const SizedBox(height: 12),
            CustomTextFieldBalita(
              label: "NIK Ortu",
              hint: "Masukkan NIK orang tua",
              controller: _nikOrtuController,
              keyboardType: TextInputType.number,
              errorText: _nikOrtuError,
            ),
            const SizedBox(height: 12),
            CustomTextFieldBalita(
              label: "No Telp",
              hint: "Masukkan nomor telepon",
              controller: _noTelpController,
              keyboardType: TextInputType.phone,
              errorText: _noTelpError,
            ),
            const SizedBox(height: 12),
            CustomTextFieldBalita(
              label: "Alamat",
              hint: "Masukkan alamat lengkap",
              controller: _alamatController,
              maxLines: 2,
              errorText: _alamatError,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField2(
                    label: "RT",
                    hint: "RT",
                    controller: _rtController,
                    keyboardType: TextInputType.number,
                    errorText: _rtError,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField2(
                    label: "RW",
                    hint: "RW",
                    controller: _rwController,
                    keyboardType: TextInputType.number,
                    errorText: _rwError,
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
                _isLoading ? "Menyimpan..." : "Selanjutnya",
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
