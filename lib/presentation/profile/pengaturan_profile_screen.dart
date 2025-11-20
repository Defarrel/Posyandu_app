import 'package:flutter/material.dart';
import 'package:posyandu_app/core/constant/constants.dart';

class PengaturanProfileScreen extends StatefulWidget {
  const PengaturanProfileScreen({super.key});

  @override
  State<PengaturanProfileScreen> createState() => _PengaturanProfileScreenState();
}

class _PengaturanProfileScreenState extends State<PengaturanProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Pengaturan Profile",
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