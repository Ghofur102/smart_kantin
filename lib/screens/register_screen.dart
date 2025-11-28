import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'package:smart_kantin/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (fullName.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua bidang harus diisi')));
      return;
    }

    final emailRegex = RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}");
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Format email tidak valid')));
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password minimal 6 karakter')));
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password dan konfirmasi tidak cocok')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uid = await AuthService.instance.register(fullName: fullName, email: email, password: password);
      if (uid == null) throw Exception('Gagal mendaftar');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pendaftaran berhasil!')));
      Navigator.pop(context);
    } catch (e) {
      final err = e.toString();
      if (err.contains('CONFIGURATION_NOT_FOUND') || err.contains('RecaptchaAction')) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konfigurasi Firebase Web belum diatur: jalankan `flutterfire configure` atau jalankan di emulator / device Android/iOS')));
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mendaftar: $err')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Title
              const Text(
                'Buat Akun Baru',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bergabunglah dengan Smart Kantin',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Full Name Field
              CustomTextField(
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkap Anda',
                controller: _fullNameController,
              ),

              // Email Field
              CustomTextField(
                label: 'Email',
                hint: 'Masukkan email Anda',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              // Password Field
              CustomTextField(
                label: 'Password',
                hint: 'Masukkan password Anda',
                controller: _passwordController,
                obscureText: true,
              ),

              // Confirm Password Field
              CustomTextField(
                label: 'Konfirmasi Password',
                hint: 'Masukkan kembali password Anda',
                controller: _confirmPasswordController,
                obscureText: true,
              ),

              // Register Button
              CustomButton(
                label: 'Daftar',
                isLoading: _isLoading,
                onPressed: _handleRegister,
              ),
              const SizedBox(height: 16),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Sudah punya akun? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Masuk di sini',
                      style: TextStyle(
                        color: Color(0xFF2E79DB),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
