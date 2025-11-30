import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_kantin/firebase_options.dart';
import 'package:smart_kantin/models/products_model.dart';
import 'package:smart_kantin/services/auth_service.dart';
import 'package:smart_kantin/screens/login_screen.dart';
import 'package:smart_kantin/screens/register_screen.dart';
import 'package:smart_kantin/screens/home_screen.dart';
import 'package:smart_kantin/screens/cart_screen.dart';
import 'package:smart_kantin/screens/profile_screen.dart';
import 'package:smart_kantin/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi koneksi ke Firebase
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // initialize auth service listeners
    AuthService.instance.init();
    firebaseInitialized = true;
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }
  
  String? uid;
  if (firebaseInitialized) {
    // menambahkan product seeder
    try {
      await ProductsModel.seederProducts();
    } catch (e) {
      debugPrint('Error running seeder: $e');
    }
  
    // cek session user saat aplikasi dibuka
    try {
      uid = await AuthService.instance.getLoggedInUserId();
    } catch (e) {
      debugPrint('Error retrieving user session: $e');
      uid = null;
    }
  }
  runApp(MyApp(initialUid: uid));
}

class MyApp extends StatelessWidget {
  final String? initialUid;
  const MyApp({super.key, this.initialUid});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Kantin',
      theme: AppTheme.lightTheme(),
      home: StreamBuilder(
        stream: AuthService.instance.userStream,
        builder: (context, snapshot) {
          // if stream not yet connected, use initialUid as fallback
          if (snapshot.connectionState == ConnectionState.waiting) {
            return initialUid == null ? const LoginScreen() : const HomeScreen();
          }

          if (snapshot.hasData && snapshot.data != null) {
            return const HomeScreen();
          }

          return const LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/cart': (context) => const CartScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
