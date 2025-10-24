import 'package:flutter/material.dart';

class GrafikBulananScreen extends StatefulWidget {
  const GrafikBulananScreen({super.key});

  @override
  State<GrafikBulananScreen> createState() => _GrafikBulananScreenState();
}

class _GrafikBulananScreenState extends State<GrafikBulananScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Grafik Bulanan")),
      body: const Center(child: Text("Grafik Bulanan")),
    );
  }
}
