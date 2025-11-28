import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

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
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pendaftaran berhasil!')));

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mendaftar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
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
                controller:
                    TextEditingController(), // tambahkan controller jika ingin simpan ke Firebase
              ),

              // Full Name 
              CustomTextField(
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkap Anda',
                controller: _fullNameController,
              ),

              // Email 
              CustomTextField(
                label: 'Email',
                hint: 'Masukkan email Anda',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              // Password
              CustomTextField(
                label: 'Password',
                hint: 'Masukkan password Anda',
                controller: _passwordController,
                obscureText: true,
              ),

              // Confirm Password 
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
