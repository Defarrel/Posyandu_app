import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:posyandu_app/core/components/custom_snackbar.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/models/request/auth/auth_request_model.dart';
import 'package:posyandu_app/data/repository/auth_repository.dart';
import 'package:posyandu_app/presentation/home/home_root.dart';
import 'package:posyandu_app/services/services_http_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  late AuthRepository _authRepository;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository(ServiceHttpClient());

    _loadSavedCredentials();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  Future<void> _loadSavedCredentials() async {
    final savedUsername = await _storage.read(key: 'saved_username');
    final savedPassword = await _storage.read(key: 'saved_password');
    if (savedUsername != null && savedPassword != null) {
      setState(() {
        _usernameController.text = savedUsername;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
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
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(message: (error), type: SnackBarType.error),
        );
      },
      (response) async {
        await _storage.write(key: 'token', value: response.token ?? '');
        await _storage.write(key: 'username', value: _usernameController.text);

        if (_rememberMe) {
          await _storage.write(
            key: 'saved_username',
            value: _usernameController.text,
          );
          await _storage.write(
            key: 'saved_password',
            value: _passwordController.text,
          );
        } else {
          await _storage.delete(key: 'saved_username');
          await _storage.delete(key: 'saved_password');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(
            message: ("Login berhasil"),
            type: SnackBarType.success,
          ),
        );

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeRoot(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
      },
    );

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Hero(
                        tag: 'logo_posyandu',
                        child: Image.asset(
                          'lib/core/assets/logo.png',
                          height: 160,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Hero(
                        tag: 'judul_posyandu',
                        child: Material(
                          color: Colors.transparent,
                          child: const Text(
                            'Aplikasi Pencatatan\nPosyandu',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Username
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
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Masukkan username'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    // Password
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
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Masukkan kata sandi'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) =>
                              setState(() => _rememberMe = value ?? false),
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
                    const SizedBox(height: 16),
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
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.blue,
                                ),
                              )
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
            ],
          ),
        ),
      ),
    );
  }
}
