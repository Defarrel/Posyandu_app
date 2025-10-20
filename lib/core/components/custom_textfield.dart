import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final int maxLines;
  final TextEditingController? controller;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label di atas field
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2196F3),
              ),
            ),
          ),

          // Text field
          SizedBox(
            width: screenWidth,
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: _getKeyboardType(label),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF2196F3),
                    width: 1.5,
                  ),
                ),
              ),
              validator: (value) => _validateInput(label, value),
            ),
          ),
        ],
      ),
    );
  }

  // Menentukan jenis keyboard
  TextInputType _getKeyboardType(String label) {
    if (label.toLowerCase().contains("nik") ||
        label.toLowerCase().contains("no telp")) {
      return TextInputType.number;
    }
    return TextInputType.text;
  }

  // Fungsi validasi sesuai jenis isian
  String? _validateInput(String label, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kolom $label wajib diisi';
    }

    // Validasi khusus NIK
    if (label.toLowerCase().contains("nik")) {
      if (value.length != 16) {
        return 'NIK harus terdiri dari 16 angka';
      }
      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
        return 'NIK hanya boleh berisi angka';
      }
    }

    // Validasi khusus No Telp
    if (label.toLowerCase().contains("no telp")) {
      if (value.length < 10 || value.length > 13) {
        return 'Nomor telepon tidak valid';
      }
      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
        return 'Nomor telepon hanya boleh berisi angka';
      }
    }

    // Validasi Nama
    if (label.toLowerCase().contains("nama")) {
      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
        return 'Nama hanya boleh berisi huruf';
      }
    }

    return null; // valid
  }
}
