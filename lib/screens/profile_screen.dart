import 'package:flutter/material.dart';
import 'package:smart_kantin/models/users_model.dart';
import 'package:smart_kantin/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UsersModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.instance.fetchCurrentUserModel();
    if (!mounted) return;
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    await AuthService.instance.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout))
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('Pengguna tidak ditemukan'))
              : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text('Nama: ${_user!.fullName}', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('Email: ${_user!.email}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      if (_user!.userId != null) Text('NIM: ${_user!.userId}', style: const TextStyle(fontSize: 16)),
                      if (_user!.userId != null) const SizedBox(height: 8),
                      const Divider(),
                    ],
                  ),
                ),
    );
  }
}