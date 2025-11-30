import 'package:flutter/material.dart';
import 'package:posyandu_app/core/components/custom_snackbar.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/repository/auth_repository.dart';
import 'package:posyandu_app/services/services_http_client.dart';

class EditPasswordScreen extends StatefulWidget {
  const EditPasswordScreen({super.key});

  @override
  State<EditPasswordScreen> createState() => _EditPasswordScreenState();
}

class _EditPasswordScreenState extends State<EditPasswordScreen> {
  final TextEditingController _pwLamaController = TextEditingController();
  final TextEditingController _pwBaruController = TextEditingController();
  final AuthRepository _repo = AuthRepository(ServiceHttpClient());
  bool _isLoading = false;

  void _updatePassword() async {
    if (_pwLamaController.text.isEmpty || _pwBaruController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.show(
          message: "Semua kolom harus diisi",
          type: SnackBarType.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final response = await _repo.updatePassword(
      _pwLamaController.text,
      _pwBaruController.text,
    );
    setState(() => _isLoading = false);

    response.fold(
      (err) => ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.show(message: "Gagal: $err", type: SnackBarType.error),
      ),
      (msg) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(
            message: "Password berhasil diubah",
            type: SnackBarType.success,
          ),
        );
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Ubah Password",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _pwLamaController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password Lama",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pwBaruController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password Baru",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : _updatePassword,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Simpan Password",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
