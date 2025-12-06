import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_kantin/services/auth_service.dart';

import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // tf = TextField
  final _tfNimControllerhuda = TextEditingController();
  final _tfFullNameControllerhuda = TextEditingController();
  final _tfEmailControllerhuda = TextEditingController();
  final _tfPasswordControllerhuda = TextEditingController();
  final _tfConfirmPasswordControllerhuda = TextEditingController();
  bool _isLoadingButtonhuda = false;

  @override
  void dispose() {
    _tfNimControllerhuda.dispose();
    _tfFullNameControllerhuda.dispose();
    _tfEmailControllerhuda.dispose();
    _tfPasswordControllerhuda.dispose();
    _tfConfirmPasswordControllerhuda.dispose();
  final _fullNameController = TextEditingController();
  final _nimController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegisterButtonhuda() async {
    setState(() {
      _isLoadingButtonhuda = true;
    });

    try {
      // Basic validation
      final nim = _nimController.text.trim();
      final fullName = _fullNameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;

      if (nim.isEmpty || fullName.isEmpty || email.isEmpty || password.isEmpty) {
        throw Exception('Semua field wajib diisi.');
      }
      if (password != confirmPassword) {
        throw Exception('Password dan konfirmasi password tidak cocok.');
      }

      // Use AuthService to register and save profile
      final uid = await AuthService.instance.register(
        fullName: fullName,
        email: email,
        password: password,
        nim: nim,
      );

      if (uid == null) throw Exception('Gagal membuat akun.');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pendaftaran berhasil!')),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (ehuda) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mendaftar: $ehuda')));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      String message = 'Gagal mendaftar: ';
      if (e is FirebaseAuthException) {
        message += e.message ?? e.code;
      } else {
        message += e.toString();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingButtonhuda = false;
        });
      }
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

              // UserID (NIM)
              CustomTextField(
                label: 'UserID (NIM)',
                hint: 'Masukkan NIM ',
                controller: _tfNimControllerhuda,
                controller: _nimController,
              ),

              // Full Name
              CustomTextField(
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkap Anda',
                controller: _tfFullNameControllerhuda,
              ),

              // Email
              CustomTextField(
                label: 'Email',
                hint: 'Masukkan email Anda',
                controller: _tfEmailControllerhuda,
                keyboardType: TextInputType.emailAddress,
              ),

              // Password
              CustomTextField(
                label: 'Password',
                hint: 'Masukkan password Anda',
                controller: _tfPasswordControllerhuda,
                obscureText: true,
              ),

              // Confirm Password
              CustomTextField(
                label: 'Konfirmasi Password',
                hint: 'Masukkan kembali password Anda',
                controller: _tfConfirmPasswordControllerhuda,
                obscureText: true,
              ),

              // Register Button
              CustomButton(
                label: 'Daftar',
                isLoading: _isLoadingButtonhuda,
                onPressed: _handleRegisterButtonhuda,
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
                      'Masuk',
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
