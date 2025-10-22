import 'package:flutter/material.dart';
import 'package:posyandu_app/core/components/custom_navbar_bot.dart';
import 'package:posyandu_app/core/components/custom_radio_button.dart';
import 'package:posyandu_app/core/components/custom_textfield.dart';
import 'package:posyandu_app/presentation/home/home_root.dart';

class TambahBalitaScreen extends StatefulWidget {
  const TambahBalitaScreen({Key? key}) : super(key: key);

  @override
  State<TambahBalitaScreen> createState() => _TambahBalitaScreenState();
}

class _TambahBalitaScreenState extends State<TambahBalitaScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _jenisKelamin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // === APPBAR ===
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tambah Data Balita Baru",
              style: TextStyle(
                color: Color(0xFF0085FF),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Silahkan lengkapi data sesuai dengan kolom.",
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF0085FF),
            size: 18,
          ),
          onPressed: () => HomeRoot.navigateToTab(context, 1),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.menu, color: Color(0xFF0085FF)),
          ),
        ],
      ),

      // === BODY ===
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomTextFieldBalita(
                label: "Nama Balita",
                hint: "Masukkan nama lengkap balita",
              ),
              const CustomTextFieldBalita(
                label: "TTL",
                hint: "Masukkan tempat dan tanggal lahir",
              ),
              const CustomTextFieldBalita(
                label: "NIK Balita",
                hint: "Masukkan NIK balita",
              ),

              // === RADIO JENIS KELAMIN ===
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomRadioBalita(
                      groupValue: _jenisKelamin,
                      onChanged: (value) {
                        setState(() {
                          _jenisKelamin = value;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const CustomTextFieldBalita(
                label: "Nama Ortu",
                hint: "Masukkan nama orang tua",
              ),
              const CustomTextFieldBalita(
                label: "NIK Ortu",
                hint: "Masukkan NIK orang tua",
              ),
              const CustomTextFieldBalita(
                label: "No Telp",
                hint: "Masukkan nomor telepon",
              ),
              const CustomTextFieldBalita(
                label: "Alamat",
                hint: "Masukkan alamat lengkap",
                maxLines: 2,
              ),

              const SizedBox(height: 30),

              // === BUTTON SIMPAN ===
              ElevatedButton(
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
                      const SnackBar(content: Text('Data berhasil disimpan!')),
                    );
                  }
                },
                child: const Text(
                  "Selanjutnya",
                  style: TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

    );
  }
}
