import 'package:flutter/material.dart';

import 'package:posyandu_app/core/constant/constants.dart';

class CustomAppBarHome extends StatelessWidget implements PreferredSizeWidget {
  final String nama;
  final String posyandu;
  final VoidCallback? onMenuTap;

  const CustomAppBarHome({
    super.key,
    required this.nama,
    required this.posyandu,
    this.onMenuTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(230);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: SlightUpCurveClipper(),
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
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 25,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage('lib/core/assets/profile.jpg'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Halo, Selamat Datang',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        Text(
                          nama,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
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

class SlightUpCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - 25);
    path.quadraticBezierTo(
      size.width / 2,
      size.height - 60,
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
