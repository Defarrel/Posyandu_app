import 'package:flutter/material.dart';
import 'package:posyandu_app/core/components/custom_texfield2.dart';
import 'package:posyandu_app/core/components/custom_dropdown_field.dart';
import 'package:posyandu_app/core/constant/colors.dart';

class TambahPerkembanganBalita extends StatefulWidget {
  final String nikBalita;
  const TambahPerkembanganBalita({super.key, required this.nikBalita});

  @override
  State<TambahPerkembanganBalita> createState() =>
      _TambahPerkembanganBalitaState();
}

class _TambahPerkembanganBalitaState extends State<TambahPerkembanganBalita> {
  final _beratController = TextEditingController();
  final _tinggiController = TextEditingController();
  final _lingkarLenganController = TextEditingController();
  final _lingkarKepalaController = TextEditingController();

  String? _selectedBulan;
  String? _caraUkur = "Berdiri";
  String? _kms;
  String? _imd;
  String? _vitaminA;
  String? _asiEks;

  bool _isLoading = false;

  final List<String> bulanList = [
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

  bool get isSpecialMonth =>
      _selectedBulan == "Februari" || _selectedBulan == "Agustus";

  void _submitForm() async {
    if (_selectedBulan == null ||
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
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data perkembangan berhasil disimpan!")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF9F9),
        elevation: 0,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Silahkan lengkapi data sesuai dengan kolom.",
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 20),

            CustomDropdownField(
              label: "Bulan",
              value: _selectedBulan,
              items: bulanList,
              onChanged: (val) => setState(() => _selectedBulan = val),
            ),

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

            SizedBox(height: 10),

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

            SizedBox(height: 10),

            CustomDropdownField(
              label: "Cara Ukur",
              value: _caraUkur,
              items: ["Berdiri", "Telentang"],
              onChanged: (val) => setState(() => _caraUkur = val),
            ),

            Row(
              children: [
                Expanded(
                  child: CustomDropdownField2(
                    label: "KMS",
                    value: _kms,
                    items: ["Merah", "Hijau"],
                    onChanged: (val) => setState(() => _kms = val),
                    enabled: isSpecialMonth,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomDropdownField2(
                    label: "IMD",
                    value: _imd,
                    items: ["Ya", "Tidak"],
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
                    items: ["Sudah", "Belum"],
                    onChanged: (val) => setState(() => _vitaminA = val),
                    enabled: isSpecialMonth,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomDropdownField2(
                    label: "ASI Eksklusif",
                    value: _asiEks,
                    items: ["Ya", "Tidak"],
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
