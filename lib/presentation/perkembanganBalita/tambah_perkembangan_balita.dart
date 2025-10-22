import 'package:flutter/material.dart';

class TambahPerkembanganBalita extends StatefulWidget {
  final String nikBalita;
  const TambahPerkembanganBalita({super.key, required this.nikBalita});

  @override
  State<TambahPerkembanganBalita> createState() =>
      _TambahPerkembanganBalitaState();
}

class _TambahPerkembanganBalitaState extends State<TambahPerkembanganBalita> {
  String? _selectedBulan;
  String? _caraUkur = "Berdiri";
  String? _kms;
  String? _imd;
  String? _vitaminA;
  String? _asiEks;
  final _beratController = TextEditingController();
  final _tinggiController = TextEditingController();
  final _lingkarLenganController = TextEditingController();
  final _lingkarKepalaController = TextEditingController();

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

  Widget _buildDropdownTile({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: enabled ? Colors.grey[300] : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            hint: Text(label),
            isExpanded: true,
            onChanged: enabled ? onChanged : null,
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildInputTile(
    String label,
    TextEditingController controller, {
    String? suffix,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              decoration: const BoxDecoration(
                color: Color(0xFF0085FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: suffix != null ? "0 $suffix" : "Isi data",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
    await Future.delayed(const Duration(seconds: 1)); // simulasi
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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0085FF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tambah Data Perkembangan Balita",
          style: TextStyle(
            color: Color(0xFF0085FF),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Silahkan lengkapi data sesuai dengan kolom.",
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Bulan
            _buildDropdownTile(
              label: "Bulan",
              value: _selectedBulan,
              items: bulanList,
              onChanged: (val) => setState(() => _selectedBulan = val),
            ),

            const SizedBox(height: 10),

            // Berat dan Tinggi
            Row(
              children: [
                _buildInputTile("Berat Badan", _beratController, suffix: "kg"),
                const SizedBox(width: 10),
                _buildInputTile(
                  "Tinggi Badan",
                  _tinggiController,
                  suffix: "cm",
                ),
              ],
            ),

            Row(
              children: [
                _buildInputTile(
                  "Lingkar Lengan",
                  _lingkarLenganController,
                  suffix: "cm",
                ),
                const SizedBox(width: 10),
                _buildInputTile(
                  "Lingkar Kepala",
                  _lingkarKepalaController,
                  suffix: "cm",
                ),
              ],
            ),

            // Cara ukur
            _buildDropdownTile(
              label: "Cara Ukur",
              value: _caraUkur,
              items: ["Berdiri", "Berbaring"],
              onChanged: (val) => setState(() => _caraUkur = val),
            ),

            const SizedBox(height: 10),

            // KMS & IMD
            Row(
              children: [
                _buildDropdownTile(
                  label: "KMS",
                  value: _kms,
                  enabled: isSpecialMonth,
                  items: ["Merah", "Kuning", "Hijau"],
                  onChanged: (val) => setState(() => _kms = val),
                ),
                const SizedBox(width: 10),
                _buildDropdownTile(
                  label: "IMD",
                  value: _imd,
                  enabled: isSpecialMonth,
                  items: ["Ya", "Tidak"],
                  onChanged: (val) => setState(() => _imd = val),
                ),
              ],
            ),

            // Vitamin A & ASI Eksklusif
            Row(
              children: [
                _buildDropdownTile(
                  label: "Vitamin A",
                  value: _vitaminA,
                  enabled: isSpecialMonth,
                  items: ["Sudah", "Belum"],
                  onChanged: (val) => setState(() => _vitaminA = val),
                ),
                const SizedBox(width: 10),
                _buildDropdownTile(
                  label: "ASI Eksklusif",
                  value: _asiEks,
                  enabled: isSpecialMonth,
                  items: ["Ya", "Tidak"],
                  onChanged: (val) => setState(() => _asiEks = val),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Tombol Simpan
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0085FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 48),
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
