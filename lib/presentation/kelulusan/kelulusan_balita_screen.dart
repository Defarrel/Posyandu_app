import 'package:flutter/material.dart';
import 'package:posyandu_app/core/constant/colors.dart';

class KelulusanBalitaScreen extends StatefulWidget {
  const KelulusanBalitaScreen({super.key});

  @override
  State<KelulusanBalitaScreen> createState() => _KelulusanBalitaScreenState();
}

class _KelulusanBalitaScreenState extends State<KelulusanBalitaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Kelulusan Balita",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
