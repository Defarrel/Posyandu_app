import 'package:flutter/material.dart';
import 'package:posyandu_app/core/components/posyandu_background_painter.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/models/response/auth/auth_response_model.dart';
import 'package:posyandu_app/data/repository/auth_repository.dart';
import 'package:posyandu_app/services/services_http_client.dart';
import 'package:posyandu_app/services/user_notifier.dart';

// Import halaman PengaturanProfileScreen
import 'package:posyandu_app/presentation/profile/pengaturan_profile_screen.dart';

class CustomAppBarHome extends StatefulWidget implements PreferredSizeWidget {
  final String posyandu;
  final VoidCallback? onMenuTap;

  const CustomAppBarHome({
    super.key,
    required this.posyandu,
    this.onMenuTap,
    String? nama,
  });

  @override
  Size get preferredSize => const Size.fromHeight(200);

  @override
  State<CustomAppBarHome> createState() => _CustomAppBarHomeState();
}

class _CustomAppBarHomeState extends State<CustomAppBarHome> {
  final AuthRepository _repo = AuthRepository(ServiceHttpClient());
  bool isNotifOpen = false;

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

  void _goToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PengaturanProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: SlightUpCurveClipper(),
      child: Container(
        height: widget.preferredSize.height,
        width: double.infinity,
        color: AppColors.primary,
        child: Stack(
          children: [
            const Positioned.fill(child: SeamlessPattern(offset: 1.0)),

            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 50,
                bottom: 25,
              ),
              child: ValueListenableBuilder<User?>(
                valueListenable: UserNotifier.user,
                builder: (context, user, child) {
                  final String namaTampil = user?.username ?? "Kader Posyandu";

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                              radius: 30,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: imageProvider,
                              onBackgroundImageError: (_, __) {},
                            ),
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Halo, Selamat Datang',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  namaTampil,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              setState(() {
                                isNotifOpen = !isNotifOpen;
                              });
                            },
                            icon: Icon(
                              isNotifOpen
                                  ? Icons.notifications_off_outlined
                                  : Icons.notifications_none,
                              color: Colors.white,
                            ),
                          ),

                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.white,
                            ),
                            onSelected: (val) {
                              if (val == 'settings') {
                                _goToSettings();
                              } else {
                                if (widget.onMenuTap != null) {
                                  widget.onMenuTap!();
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem<String>(
                                value: 'settings',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.settings,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text("Pengaturan Akun"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                },
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
