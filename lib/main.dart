import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:smart_kantin/firebase_options.dart';
import 'package:smart_kantin/models/products_model.dart';
import 'package:smart_kantin/services/auth_service.dart';
import 'package:smart_kantin/providers/cart_provider.dart';
import 'package:smart_kantin/screens/login_screen.dart';
import 'package:smart_kantin/screens/register_screen.dart';
import 'package:smart_kantin/screens/home_screen.dart';
import 'package:smart_kantin/screens/cart_screen.dart';
import 'package:smart_kantin/screens/profile_screen.dart';
import 'package:smart_kantin/screens/admin_products_screen.dart';
import 'package:smart_kantin/screens/product_form_screen.dart';
import 'package:smart_kantin/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi koneksi ke Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Provide a clearer message when Firebase isn't configured for the current platform
    // For example, running the app on Flutter web without a web configuration can cause
    // recaptcha / auth configuration errors. Run `flutterfire configure` to add the web
    // configuration options.
    // Print to console and keep app running to allow debugging screens to show.
    // In production, consider failing fast or showing a friendly UI message.
    // Re-throw the error if you prefer the app to crash during development.
    // debugPrint prints to console so developer can see error in logs.
    debugPrint('Error initializing Firebase: $e');
  }
  // menambahkan product seeder
  await ProductsModel.seederProducts_ghofur();

  // cek session user saat aplikasi dibuka
  final uid = await AuthService.instance.getLoggedInUserId();
  runApp(MyApp(initialUid: uid));
}

class MyApp extends StatelessWidget {
  final String? initialUid;
  const MyApp({super.key, this.initialUid});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Kantin',
        theme: AppTheme.lightTheme(),
        home: initialUid == null ? const LoginScreen() : const HomeScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/cart': (context) => const CartScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/admin/products': (context) => const AdminProductsScreen(),
          '/admin/product_form': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            if (args is ProductsModel) {
              return ProductFormScreen(product: args);
            }
            return const ProductFormScreen();
          },
        },
      ),
    );
  }
}
