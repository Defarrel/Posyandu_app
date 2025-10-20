import 'package:flutter/material.dart';

class CustomRadioButton extends StatefulWidget {
  final String? groupValue;
  final ValueChanged<String?> onChanged;

  const CustomRadioButton({
    Key? key,
    required this.groupValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<CustomRadioButton> createState() => _CustomRadioButtonState();
}

class _CustomRadioButtonState extends State<CustomRadioButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Jenis Kelamin",
          style: TextStyle(
            color: Color(0xFF0085FF),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                value: "Laki-laki",
                groupValue: widget.groupValue,
                onChanged: widget.onChanged,
                title: const Text("Laki - laki"),
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                value: "Perempuan",
                groupValue: widget.groupValue,
                onChanged: widget.onChanged,
                title: const Text("Perempuan"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
