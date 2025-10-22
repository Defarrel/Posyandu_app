import 'package:flutter/material.dart';

class CustomRadioBalita extends StatelessWidget {
  final String? groupValue;
  final ValueChanged<String?> onChanged;

  const CustomRadioBalita({
    super.key,
    required this.groupValue,
    required this.onChanged,
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
            
            Container(
              width: 110,
              height: 100,
              alignment: Alignment.center,
              color: const Color(0xFF0098F8),
              child: const Text(
                "Jenis Kelamin",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),

            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 12, 
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<String>(
                          value: "Laki-laki",
                          groupValue: groupValue,
                          onChanged: onChanged,
                          activeColor: const Color(0xFF0098F8),
                        ),
                        const Text("Laki - laki"),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<String>(
                          value: "Perempuan",
                          groupValue: groupValue,
                          onChanged: onChanged,
                          activeColor: const Color(0xFF0098F8),
                        ),
                        const Text("Perempuan"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
