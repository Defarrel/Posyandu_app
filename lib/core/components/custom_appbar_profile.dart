import 'package:flutter/material.dart';
import 'package:posyandu_app/core/constant/constants.dart';

class CustomAppBarProfile extends StatelessWidget {
  final String nama;
  final String posyandu;
  final VoidCallback? onBack;

  const CustomAppBarProfile({
    super.key,
    required this.nama,
    required this.posyandu,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: SlightDownCurveClipper(),
      child: Container(
        height: 230,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.accent, AppColors.primary],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('lib/core/assets/profile.jpg'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    nama,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    posyandu,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SlightDownCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 25);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 10, // lembut, tidak menonjol
      size.width,
      size.height - 25,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
