import 'package:flutter/material.dart';

class CustomTextFieldBalita extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final int maxLines;
  final TextInputType keyboardType;

  const CustomTextFieldBalita({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: const Color(0xFFD9D9D9),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // === Bagian label biru ===
            Container(
              width: 110,
              height: maxLines > 1 ? 70 : 48,
              alignment: Alignment.center,
              color: const Color(0xFF0098F8),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),

            // === TextField abu-abu menyatu ===
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                maxLines: maxLines,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(color: Colors.black45),
                  filled: true,
                  fillColor: const Color(0xFFD9D9D9),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
