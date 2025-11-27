import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:posyandu_app/core/constant/constants.dart';
import 'package:posyandu_app/core/components/custom_appbar_profile.dart';
import 'package:posyandu_app/presentation/profile/pengaturan_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  String _username = "Memuat...";
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final nama = await _storage.read(key: 'username');
    setState(() {
      _username = nama ?? "Kader Posyandu";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 250, 20, 30),
                children: [
                  _buildSectionHeader(
                    icon: Icons.person_rounded,
                    title: "Informasi Akun",
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  _buildModernInfoCard([
                    _InfoItem(Icons.person_outline, "Nama Pengguna", _username),
                    _InfoItem(Icons.home_rounded, "Posyandu", "Dahlia X"),
                  ]),

                  const SizedBox(height: 32),

                  _buildSectionHeader(
                    icon: Icons.settings_rounded,
                    title: "Pengaturan",
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  _buildModernInfoCard([
                    _SettingItem(
                      Icons.person_rounded,
                      "Pengaturan Profil",
                      "Ubah password dan nama pengguna",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PengaturanProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 32),

                  _buildSectionHeader(
                    icon: Icons.info_outline_rounded,
                    title: "Tentang Aplikasi",
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  _buildModernInfoCard([
                    _InfoItem(Icons.code_rounded, "Versi Aplikasi", "v1.0.0"),
                    _InfoItem(
                      Icons.update_rounded,
                      "Update Terakhir",
                      "Oktober 2025",
                    ),
                  ]),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomAppBarProfile(
              posyandu: "Posyandu Dahlia X",
              onBack: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildModernInfoCard(List<dynamic> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          final isSetting = item is _SettingItem;
          final icon = item.icon;
          final title = item.title;
          final subtitle = item.subtitle;

          return Column(
            children: [
              InkWell(
                onTap: isSetting ? item.onTap : null,
                borderRadius: BorderRadius.circular(20),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.15),
                          AppColors.primary.withOpacity(0.4),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 24),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  trailing: isSetting
                      ? const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: AppColors.primary,
                        )
                      : null,
                ),
              ),

              if (index < items.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(color: Colors.grey.shade200, height: 1),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String title;
  final String subtitle;

  _InfoItem(this.icon, this.title, this.subtitle);
}

class _SettingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _SettingItem(this.icon, this.title, this.subtitle, {required this.onTap});
}
