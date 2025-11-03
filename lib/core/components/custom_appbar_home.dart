import 'package:flutter/material.dart';
import 'package:posyandu_app/core/constant/colors.dart';

class CustomAppBarHome extends StatelessWidget implements PreferredSizeWidget {
  final String nama;
  final String posyandu;
  final VoidCallback? onMenuTap;
  final double preferredHeight;
  final double transitionFactor;

  const CustomAppBarHome({
    super.key,
    required this.nama,
    required this.posyandu,
    this.onMenuTap,
    this.preferredHeight = 230,
    this.transitionFactor = 0.0,
  });

  @override
  Size get preferredSize => Size.fromHeight(preferredHeight);

  @override
  Widget build(BuildContext context) {
    final double disappear = (1 - (transitionFactor * 2)).clamp(0.0, 1.0);

    return ClipPath(
      clipper: SlightUpCurveClipper(transitionFactor: transitionFactor),
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
            Positioned(
              top: 40,
              right: 20,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: disappear,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onMenuTap,
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: Tween<double>(
                  begin: 60,
                  end: 20,
                ).transform(transitionFactor),
                bottom: 25,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage(
                        'lib/core/assets/profile.jpg',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Halo, Selamat Datang 👋',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          nama,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: disappear,
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
  final double transitionFactor;

  SlightUpCurveClipper({this.transitionFactor = 0.0});

  @override
  Path getClip(Size size) {
    final path = Path();

    const double initialHeightOffset = 25;
    const double initialControlPointOffset = 60;

    final double endY = Tween<double>(
      begin: size.height - initialHeightOffset,
      end: size.height,
    ).transform(transitionFactor);
    final double controlPointY = Tween<double>(
      begin: size.height - initialControlPointOffset,
      end: size.height,
    ).transform(transitionFactor);

    path.lineTo(0, endY);
    path.quadraticBezierTo(size.width / 2, controlPointY, size.width, endY);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return oldClipper is SlightUpCurveClipper &&
        oldClipper.transitionFactor != transitionFactor;
  }
}
