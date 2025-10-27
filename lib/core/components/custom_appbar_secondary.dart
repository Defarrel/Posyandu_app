import 'package:flutter/material.dart';
import 'package:posyandu_app/core/constant/colors.dart';

class CustomAppBarSecondary extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;

  const CustomAppBarSecondary({
    super.key,
    required this.title,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(160);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: InvertedCurveClipper(),
      child: Container(
        height: preferredSize.height,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Positioned(
                left: 10,
                top: 8,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: onBack ?? () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lengkungan kebalikan dari SlightUpCurveClipper,
/// tapi dibuat simetris agar nyambung sempurna dengan home.
class InvertedCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // mulai dari kiri atas (cekung ke atas)
    path.moveTo(0, 25);
    path.quadraticBezierTo(
      size.width / 2,
      60, // nilai ini menyesuaikan kedalaman curve di home
      size.width,
      25,
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
