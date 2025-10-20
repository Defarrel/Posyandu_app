import 'package:flutter/material.dart';
import '../../core/components/custom_textfield.dart';
import '../../core/components/custom_navbar_bot.dart';
import '../../core/components/custom_radio_button.dart';

class TambahDataBalitaPage extends StatefulWidget {
  const TambahDataBalitaPage({Key? key}) : super(key: key);

  @override
  State<TambahDataBalitaPage> createState() => _TambahDataBalitaPageState();
}

class _TambahDataBalitaPageState extends State<TambahDataBalitaPage> {
  final _formKey = GlobalKey<FormState>();
  String? _jenisKelamin;
  int _currentIndex = 1;

  void _onNavbarTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/balita');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profil');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Tambah Data Balita Baru",
          style: TextStyle(
            color: Color(0xFF0085FF),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.menu, color: Colors.black),
          ),
        ],
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Row(
              children: [
                Icon(Icons.arrow_back_ios, color: Colors.black, size: 16),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              const CustomTextField(
                label: "Nama Balita",
                hint: "Masukkan nama lengkap balita",
              ),
              const CustomTextField(
                label: "TTL",
                hint: "Masukkan tempat dan tanggal lahir",
              ),
              const CustomTextField(
                label: "NIK Balita",
                hint: "Masukkan NIK balita",
              ),

              // Radio Button
              CustomRadioButton(
                groupValue: _jenisKelamin,
                onChanged: (value) {
                  setState(() {
                    _jenisKelamin = value;
                  });
                },
              ),

              const CustomTextField(
                label: "Nama Orang Tua",
                hint: "Masukkan nama orang tua",
              ),
              const CustomTextField(
                label: "NIK Orang Tua",
                hint: "Masukkan NIK orang tua",
              ),
              const CustomTextField(
                label: "No Telepon",
                hint: "Masukkan nomor telepon",
              ),
              const CustomTextField(
                label: "Alamat",
                hint: "Masukkan alamat lengkap",
                maxLines: 3,
              ),

              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0085FF),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Data berhasil disimpan!'),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Selanjutnya",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      // Navbar
      bottomNavigationBar: CustomNavbarBot(
        currentIndex: 0, // index 0 karena ini halaman tambah balita
        onTap: (index) {},
      ),
    );
  }
}
