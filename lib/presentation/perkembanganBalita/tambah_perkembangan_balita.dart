import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:posyandu_app/data/models/request/perkembangan_balita/perkembangan_request_model.dart';
import 'package:posyandu_app/data/repository/perkembangan_balita_repository.dart';

class TambahPerkembanganBalita extends StatefulWidget {
  final String nikBalita;
  const TambahPerkembanganBalita({super.key, required this.nikBalita});

  @override
  State<TambahPerkembanganBalita> createState() =>
      _TambahPerkembanganBalitaState();
}

class _TambahPerkembanganBalitaState extends State<TambahPerkembanganBalita> {
  final _lingkarLenganController = TextEditingController();
  final _lingkarKepalaController = TextEditingController();
  final _tinggiBadanController = TextEditingController();
  final _beratBadanController = TextEditingController();
  final _caraUkurController = TextEditingController();
  final _vitaminAController = TextEditingController();
  final _kmsController = TextEditingController();
  final _imdController = TextEditingController();
  final _asiEksController = TextEditingController();

  DateTime? _selectedDate;
  bool _isLoading = false;

  String? _lingkarLenganError;
  String? _lingkarKepalaError;
  String? _tinggiBadanError;
  String? _beratBadanError;
  String? _caraUkurError;
  String? _vitaminAError;
  String? _kmsError;
  String? _imdError;
  String? _asiEksError;
  String? _tanggalPerubahanError;

  final PerkembanganBalitaRepository _repository =
      PerkembanganBalitaRepository();

  void _pickDate() async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _tanggalPerubahanError = null;
      });
    }
  }

  void _submitForm() async {
    setState(() {
      _lingkarLenganError = _lingkarLenganController.text.isEmpty
          ? "Lingkar lengan wajib diisi"
          : null;
      _lingkarKepalaError = _lingkarKepalaController.text.isEmpty
          ? "Lingkar kepala wajib diisi"
          : null;
      _tinggiBadanError = _tinggiBadanController.text.isEmpty
          ? "Tinggi badan wajib diisi"
          : null;
      _beratBadanError = _beratBadanController.text.isEmpty
          ? "Berat badan wajib diisi"
          : null;
      _caraUkurError = _caraUkurController.text.isEmpty
          ? "Cara ukur wajib diisi"
          : null;
      _vitaminAError = _vitaminAController.text.isEmpty
          ? "Vitamin A wajib diisi"
          : null;
      _kmsError = _kmsController.text.isEmpty ? "KMS wajib diisi" : null;
      _imdError = _imdController.text.isEmpty ? "IMD wajib diisi" : null;
      _asiEksError = _asiEksController.text.isEmpty
          ? "ASI Eks wajib diisi"
          : null;
      _tanggalPerubahanError = _selectedDate == null
          ? "Tanggal perubahan wajib diisi"
          : null;
    });

    if (_lingkarLenganError != null ||
        _lingkarKepalaError != null ||
        _tinggiBadanError != null ||
        _beratBadanError != null ||
        _caraUkurError != null ||
        _vitaminAError != null ||
        _kmsError != null ||
        _imdError != null ||
        _asiEksError != null ||
        _tanggalPerubahanError != null)
      return;

    setState(() => _isLoading = true);

    final perkembangan = PerkembanganBalitaRequestModel(
      nikBalita: widget.nikBalita,
      lingkarLengan: double.parse(_lingkarLenganController.text),
      lingkarKepala: double.parse(_lingkarKepalaController.text),
      tinggiBadan: double.parse(_tinggiBadanController.text),
      beratBadan: double.parse(_beratBadanController.text),
      caraUkur: _caraUkurController.text,
      vitaminA: _vitaminAController.text,
      kms: _kmsController.text,
      imd: _imdController.text,
      asiEks: _asiEksController.text,
      tanggalPerubahan:
          "${_selectedDate!.year.toString().padLeft(4, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
    );

    Either<String, String> result = await _repository.tambahPerkembangan(
      perkembangan,
    );

    result.fold(
      (error) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal: $error'))),
      (message) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        Navigator.pop(context); // kembali ke halaman sebelumnya
      },
    );

    setState(() => _isLoading = false);
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String? errorText, {
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            hintText: label,
            errorText: errorText,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Perkembangan Balita"),
        backgroundColor: const Color(0xFF0085FF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(
              "Lingkar Lengan (cm)",
              _lingkarLenganController,
              _lingkarLenganError,
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              "Lingkar Kepala (cm)",
              _lingkarKepalaController,
              _lingkarKepalaError,
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              "Tinggi Badan (cm)",
              _tinggiBadanController,
              _tinggiBadanError,
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              "Berat Badan (kg)",
              _beratBadanController,
              _beratBadanError,
              keyboardType: TextInputType.number,
            ),
            _buildTextField("Cara Ukur", _caraUkurController, _caraUkurError),
            _buildTextField("Vitamin A", _vitaminAController, _vitaminAError),
            _buildTextField("KMS", _kmsController, _kmsError),
            _buildTextField("IMD", _imdController, _imdError),
            _buildTextField("ASI Eks", _asiEksController, _asiEksError),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Tanggal Perubahan",
                    hintText: _selectedDate == null
                        ? "Pilih tanggal"
                        : "${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorText: _tanggalPerubahanError,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0085FF),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                _isLoading ? "Menyimpan..." : "Simpan",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
