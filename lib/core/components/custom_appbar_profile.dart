import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:posyandu_app/core/components/posyandu_background_painter.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/models/response/auth/auth_response_model.dart';
import 'package:posyandu_app/data/repository/auth_repository.dart';
import 'package:posyandu_app/presentation/auth/login_screen.dart';
import 'package:posyandu_app/services/services_http_client.dart';
import 'package:posyandu_app/services/user_notifier.dart';

class CustomAppBarProfile extends StatefulWidget {
  final String posyandu;
  final VoidCallback? onBack;

  const CustomAppBarProfile({super.key, required this.posyandu, this.onBack});

  @override
  State<CustomAppBarProfile> createState() => _CustomAppBarProfileState();
}

class _CustomAppBarProfileState extends State<CustomAppBarProfile> {
  final AuthRepository _repo = AuthRepository(ServiceHttpClient());

  @override
  void initState() {
    super.initState();
    _repo.getUserProfile();
  }

  String _getPhotoUrl(String filename) {
    String baseUrl = ServiceHttpClient().baseUrl;
    if (baseUrl.endsWith("api/")) {
      baseUrl = baseUrl.replaceAll("api/", "uploads/");
    } else if (baseUrl.endsWith("api")) {
      baseUrl = baseUrl.replaceAll("api", "uploads/");
    } else {
      baseUrl = "$baseUrl/uploads/";
    }
    return "$baseUrl$filename";
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah kamu yakin ingin keluar dari akun ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      const storage = FlutterSecureStorage();
      await storage.deleteAll();

      UserNotifier.update(null);

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: SlightDownCurveClipper(),
      child: Container(
        height: 200,
        width: double.infinity,
        color: Colors.transparent,
        child: Stack(
          children: [
            const Positioned.fill(child: SeamlessPattern(offset: 2.0)),

            Stack(
              children: [
                Positioned(
                  right: 10,
                  top: 30,
                  child: IconButton(
                    icon: const Icon(Icons.exit_to_app, color: Colors.white),
                    onPressed: () => _handleLogout(context),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: ValueListenableBuilder<User?>(
                    valueListenable: UserNotifier.user,
                    builder: (context, user, child) {
                      final String namaTampil =
                          user?.username ?? "Kader Posyandu";

                      ImageProvider imageProvider;
                      if (user?.fotoProfile != null &&
                          user!.fotoProfile!.isNotEmpty) {
                        imageProvider = NetworkImage(
                          _getPhotoUrl(user.fotoProfile!),
                        );
                      } else {
                        imageProvider = const AssetImage(
                          'lib/core/assets/default_profile.png',
                        );
                      }

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.8),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: imageProvider,
                              onBackgroundImageError: (_, __) {},
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            namaTampil,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.posyandu,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
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
      size.height + 10,
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
