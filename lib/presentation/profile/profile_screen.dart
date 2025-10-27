import 'package:flutter/material.dart';
import 'package:posyandu_app/core/constant/constants.dart';
import 'package:posyandu_app/core/components/custom_appbar_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          CustomAppBarProfile(
            nama: "Defarrel Danendra",
            posyandu: "Posyandu Dahlia",
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: const [
                  Text(
                    "Informasi Akun",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  ListTile(
                    title: Text("Nama Lengkap"),
                    subtitle: Text("Defarrel Danendra Praja"),
                  ),
                  ListTile(
                    title: Text("Email"),
                    subtitle: Text("defarrel@example.com"),
                  ),
                  ListTile(
                    title: Text("No Telepon"),
                    subtitle: Text("0812-3456-7890"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
