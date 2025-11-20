import 'package:flutter/material.dart';
import 'package:posyandu_app/core/constant/colors.dart';

class VaksinBalitaScreen extends StatefulWidget {
  const VaksinBalitaScreen({super.key});

  @override
  State<VaksinBalitaScreen> createState() => _VaksinBalitaScreenState();
}

class _VaksinBalitaScreenState extends State<VaksinBalitaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Vaksin Balita",
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
