import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/core/components/custom_snackbar.dart';
import 'package:posyandu_app/data/repository/auth_repository.dart';
import 'package:posyandu_app/presentation/profile/edit_foto_crop_screen.dart';
import 'package:posyandu_app/services/services_http_client.dart';
import 'package:posyandu_app/services/user_notifier.dart';

import 'package:posyandu_app/presentation/profile/camera_screen.dart';
import 'package:posyandu_app/presentation/profile/edit_nama_screen.dart';
import 'package:posyandu_app/presentation/profile/edit_password_screen.dart';

class PengaturanProfileScreen extends StatefulWidget {
  const PengaturanProfileScreen({super.key});

  @override
  State<PengaturanProfileScreen> createState() =>
      _PengaturanProfileScreenState();
}

class _PengaturanProfileScreenState extends State<PengaturanProfileScreen> {
  final AuthRepository _repo = AuthRepository(ServiceHttpClient());
  final ImagePicker _picker = ImagePicker();

  String? _currentPhoto;
  File? _selectedPhoto;

  @override
  void initState() {
    super.initState();
    final user = UserNotifier.user.value;
    _currentPhoto = user?.fotoProfile;
  }

  Future<void> _takePhoto() async {
    final File? takenPhoto = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );

    if (takenPhoto != null) {
      _openCropper(takenPhoto);
    }
  }

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _openCropper(File(picked.path));
    }
  }

  void _openCropper(File file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditFotoCropScreen(
          file: file,
          onSave: (croppedFile) async {
            setState(() {
              _selectedPhoto = croppedFile;
            });

            final result = await _repo.updateProfilePhoto(croppedFile);

            result.fold(
              (err) {
                ScaffoldMessenger.of(context).showSnackBar(
                  CustomSnackBar.show(
                    message: ("Gagal upload: $err"),
                    type: SnackBarType.error,
                  ),
                );
              },
              (msg) {
                ScaffoldMessenger.of(context).showSnackBar(
                  CustomSnackBar.show(
                    message: ("Foto berhasil diubah!"),
                    type: SnackBarType.success,
                  ),
                );

                final user = UserNotifier.user.value;
                if (user != null) {
                  UserNotifier.user.value = user.copyWith(
                    fotoProfile: msg["foto_profile"],
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _deletePhoto() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Foto?"),
        content: const Text("Foto profil akan dihapus secara permanen."),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await _repo.deleteProfilePhoto();

    result.fold(
      (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(
            message: "Gagal menghapus foto: $err",
            type: SnackBarType.error,
          ),
        );
      },
      (msg) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(
            message: "Foto berhasil dihapus!",
            type: SnackBarType.success,
          ),
        );

        setState(() {
          _selectedPhoto = null;
          _currentPhoto = null;
        });
      },
    );
  }

  void _openViewPhoto() {
    if (_currentPhoto == null && _selectedPhoto == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: _selectedPhoto != null
                  ? Image.file(_selectedPhoto!)
                  : Image.network(_getPhotoUrl(_currentPhoto!)),
            ),
          ),
        ),
      ),
    );
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

  void _openBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetItem(Icons.camera_alt, "Ambil Foto", () {
              Navigator.pop(context);
              _takePhoto();
            }),
            _sheetItem(Icons.photo_library_outlined, "Pilih Dari Galeri", () {
              Navigator.pop(context);
              _pickFromGallery();
            }),
            _sheetItem(Icons.visibility_outlined, "Lihat Foto", () {
              Navigator.pop(context);
              _openViewPhoto();
            }),
          ],
        );
      },
    );
  }

  Widget _sheetItem(IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Pengaturan Akun",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),

          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 3),
                    image: _selectedPhoto != null
                        ? DecorationImage(
                            image: FileImage(_selectedPhoto!),
                            fit: BoxFit.cover,
                          )
                        : (_currentPhoto != null)
                        ? DecorationImage(
                            image: NetworkImage(_getPhotoUrl(_currentPhoto!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.grey[300],
                  ),
                ),
                GestureDetector(
                  onTap: _openBottomSheet, 
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          GestureDetector(
            onTap: _openBottomSheet,
            child: Center(
              child: Text(
                _currentPhoto != null || _selectedPhoto != null
                    ? "Ganti Foto"
                    : "Pilih Foto",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          if (_currentPhoto != null || _selectedPhoto != null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _deletePhoto,
              child: const Center(
                child: Text(
                  "Hapus Foto",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 30),

          _menuCard(
            title: "Ubah Nama Pengguna",
            icon: Icons.person_outline,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditNamaScreen()),
            ),
          ),

          const SizedBox(height: 16),

          _menuCard(
            title: "Ubah Password",
            icon: Icons.lock_outline,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditPasswordScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
