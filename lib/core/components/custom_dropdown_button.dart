import 'package:flutter/material.dart';

class CustomDropdownButton extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final Color textColor;
  final double fontSize;
  final bool isCompact; // 🔹 Tambahan: untuk mode simple (tanpa box)

  const CustomDropdownButton({
    Key? key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.textColor = const Color.fromARGB(255, 155, 135, 135),
    this.fontSize = 14,
    this.isCompact = false, // default tampilan normal
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 🔹 Jika mode compact aktif (untuk grafik card)
    if (isCompact) {
      return DropdownButton<String>(
        value: value,
        dropdownColor: Colors.white,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      );
    }

    // 🔹 Jika mode normal (tampilan dengan box putih misalnya)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
        dropdownColor: Colors.white,
        items: items
            .map(
              (item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
