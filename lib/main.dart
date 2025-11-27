import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_kantin/firebase_options.dart';
import 'package:smart_kantin/models/products_model.dart';
import 'package:smart_kantin/screens/login_screen.dart';
import 'package:smart_kantin/screens/register_screen.dart';
import 'package:smart_kantin/screens/home_screen.dart';
import 'package:smart_kantin/screens/cart_screen.dart';
import 'package:smart_kantin/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi koneksi ke Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // menambahkan product seeder
  await ProductsModel.seederProducts();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Kantin',
      theme: AppTheme.lightTheme(),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/cart': (context) => const CartScreen(),
      },
    );
  }
}
