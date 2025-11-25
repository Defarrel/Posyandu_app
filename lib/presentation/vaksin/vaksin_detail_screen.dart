import 'package:flutter/material.dart';
import 'package:posyandu_app/core/constant/constants.dart';

class VaksinDetailScreen extends StatefulWidget {
  const VaksinDetailScreen({super.key});

  @override
  State<VaksinDetailScreen> createState() => _VaksinDetailScreenState();
}

class _VaksinDetailScreenState extends State<VaksinDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Detail Vaksin",
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
