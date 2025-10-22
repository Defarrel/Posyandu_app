import 'package:flutter/material.dart';
import 'package:posyandu_app/data/models/request/auth/login_request_model.dart';
import 'package:posyandu_app/data/repository/auth_repository.dart';
import 'package:posyandu_app/presentation/home/home_root.dart';
import 'package:posyandu_app/services/services_http_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  bool _isLoading = false;

  late AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository(ServiceHttpClient());
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final loginRequest = LoginRequestModel(
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
    );

    final result = await _authRepository.login(loginRequest);

    result.fold(
      (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      },
      (response) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Login berhasil")));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeRoot()),
        );
      },
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0098F8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hero Animation - Logo dan Judul
                  Hero(
                    tag: 'logo_posyandu',
                    child: Image.asset(
                      'lib/core/assets/ibu_bayi.png',
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Hero(
                    tag: 'judul_posyandu',
                    child: Material(
                      color: Colors.transparent,
                      child: const Text(
                        'Aplikasi Pencatatan\nPosyandu',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Field Username
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Username',
                      prefixIcon: const Icon(Icons.person_outline),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Masukkan username'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Field Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isObscure,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Kata Sandi',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _isObscure = !_isObscure),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Masukkan kata sandi'
                        : null,
                  ),
                  const SizedBox(height: 12),

                  // Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: false,
                        onChanged: (_) {},
                        activeColor: Colors.white,
                        checkColor: Colors.blue,
                        side: const BorderSide(color: Colors.white),
                      ),
                      const Text(
                        "Ingat kata sandi",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Tombol Masuk
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.blue)
                          : const Text(
                              "Masuk",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
