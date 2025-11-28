import 'package:flutter/material.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/models/response/auth/auth_response_model.dart';
import 'package:posyandu_app/data/repository/auth_repository.dart';
import 'package:posyandu_app/services/services_http_client.dart';
import 'package:posyandu_app/services/user_notifier.dart';

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

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: SlightUpCurveClipper(),
      child: Container(
        height: widget.preferredSize.height,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/core/assets/home.png'),
            fit: BoxFit.cover,
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

                  return Row(
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
                          radius: 35,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: imageProvider,
                          onBackgroundImageError: (_, __) {},
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Halo, Selamat Datang',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              namaTampil,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications_none,
                          color: Colors.white,
                        ),
                      ),

                      IconButton(
                        onPressed: widget.onMenuTap,
                        icon: const Icon(Icons.more_vert, color: Colors.white),
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
