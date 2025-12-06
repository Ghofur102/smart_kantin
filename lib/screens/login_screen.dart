import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'package:smart_kantin/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _tfEmailControllerhuda = TextEditingController();
  final _tfPasswordControllerhuda = TextEditingController();
  bool _isLoadingButtonhuda = false;

  @override
  void dispose() {
    _tfEmailControllerhuda.dispose();
    _tfPasswordControllerhuda.dispose();
    super.dispose();
  }

  Future<void> _handleLoginButtonhuda() async {
    {
      // Validasi
      final email = _tfEmailControllerhuda.text.trim();
      final password = _tfPasswordControllerhuda.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email dan password tidak boleh kosong'),
          ),
        );
        return;
      }

      final emailRegex = RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}");
      if (!emailRegex.hasMatch(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Format email tidak valid')),
        );
        return;
      }

      setState(() {
        _isLoadingButtonhuda = true;
      });

      try {
        await Future.delayed(const Duration(seconds: 2));
        // lakukan proses login
        final uid = await AuthService.instance.login(
          email: email,
          password: password,
        );

        if (uid == null) {
          throw Exception('Gagal login, periksa kredensial Anda');
        }

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login berhasil!')));

        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        if (mounted) {
          final err = e.toString();
          if (err.contains('CONFIGURATION_NOT_FOUND') ||
              err.contains('RecaptchaAction')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Konfigurasi Firebase Web belum diatur: jalankan flutterfire configure atau jalankan di emulator / device Android/iOS',
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Gagal login: $err')));
          }
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoadingButtonhuda = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Logo + Title (centered)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 150, // atur radius
                      backgroundImage: AssetImage(
                        'assets/images/logo zeKantin.png',
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Masuk Akun',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Selamat datang di zeKantin',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Email Field
              CustomTextField(
                label: 'Email',
                hint: 'Masukkan email Anda',
                controller: _tfEmailControllerhuda,
                keyboardType: TextInputType.emailAddress,
              ),

              // Password Field
              CustomTextField(
                label: 'Password',
                hint: 'Masukkan password Anda',
                controller: _tfPasswordControllerhuda,
                obscureText: true,
              ),

              // Login Button
              CustomButton(
                label: 'Masuk',
                isLoading: _isLoadingButtonhuda,
                onPressed: _handleLoginButtonhuda,
              ),
              const SizedBox(height: 16),

              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum punya akun? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      'Register',
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