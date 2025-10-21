import 'package:flutter/material.dart';

class CariBalitaScreen extends StatelessWidget {
  const CariBalitaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Data Balita'),
        backgroundColor: const Color(0xFF0098F8),
      ),
      body: const Center(
        child: Text('Halaman Cari Balita', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
