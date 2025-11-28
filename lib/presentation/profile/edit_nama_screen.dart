import 'package:flutter/material.dart';
import 'package:posyandu_app/core/components/custom_snackbar.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/repository/auth_repository.dart';
import 'package:posyandu_app/services/services_http_client.dart';
import 'package:posyandu_app/services/user_notifier.dart';

class EditNamaScreen extends StatefulWidget {
  const EditNamaScreen({super.key});

  @override
  State<EditNamaScreen> createState() => _EditNamaScreenState();
}

class _EditNamaScreenState extends State<EditNamaScreen> {
  final TextEditingController _namaController = TextEditingController();
  final AuthRepository _repo = AuthRepository(ServiceHttpClient());
  bool _isLoading = false;

  void _updateNama() async {
    if (_namaController.text.isEmpty) {
      CustomSnackBar.show(
        message: "Nama tidak boleh kosong",
        type: SnackBarType.error,
      );
      return;
    }

    setState(() => _isLoading = true);
    final response = await _repo.updateUsername(_namaController.text);
    setState(() => _isLoading = false);

    response.fold(
      (err) => ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.show(message: "Gagal: $err", type: SnackBarType.error),
      ),
      (msg) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(
            message: "Berhasil ganti nama!",
            type: SnackBarType.success,
          ),
        );
        Navigator.pop(context);
      },
    );
  }

  @override
  void initState() {
    super.initState();

    final user = UserNotifier.user.value;
    if (user != null && user.username != null) {
      _namaController.text = user.username!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Ubah Nama",
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
              controller: _namaController,
              decoration: InputDecoration(
                labelText: "Nama Baru",
                hintText: "Masukkan nama pengguna baru",
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
                onPressed: _isLoading ? null : _updateNama,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Simpan Perubahan",
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
