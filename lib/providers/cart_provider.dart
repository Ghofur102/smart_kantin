import 'package:flutter/foundation.dart';
import '../models/products_model.dart';

/// Provider untuk mengelola state keranjang belanja (cart)
/// menggunakan ChangeNotifier pattern untuk state management
class CartProvider extends ChangeNotifier {
  final List<CartItem> _cartItems = [];

  /// Getter untuk mendapatkan daftar item di keranjang
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  /// Getter untuk menghitung jumlah item unik di keranjang
  int get itemCount => _cartItems.length;

  /// Getter untuk menghitung total quantity semua item
  int get totalQuantity =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity.toInt());

  /// Getter untuk menghitung total harga tanpa diskon dan ongkir
  double get subtotal =>
      _cartItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));

  /// Tambahkan produk ke keranjang atau naikkan quantity jika sudah ada
  void addToCart(ProductsModel product, {double quantity = 1}) {
    final index = _cartItems.indexWhere(
      (item) => item.product.productId == product.productId,
    );

    if (index == -1) {
      // Produk belum ada di keranjang, tambahkan baru
      _cartItems.add(CartItem(product: product, quantity: quantity));
    } else {
      // Produk sudah ada, naikkan quantity
      _cartItems[index].quantity += quantity;
    }

    notifyListeners();
  }

  /// Hapus produk dari keranjang berdasarkan product ID
  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.productId == productId);
    notifyListeners();
  }

  /// Update quantity item di keranjang
  void updateQuantity(String productId, double newQuantity) {
    final index = _cartItems.indexWhere(
      (item) => item.product.productId == productId,
    );

    if (index != -1) {
      if (newQuantity <= 0) {
        // Jika quantity 0 atau negatif, hapus item
        _cartItems.removeAt(index);
      } else {
        // Update quantity
        _cartItems[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  /// Kosongkan semua item di keranjang
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  /// Cek apakah keranjang kosong
  bool get isEmpty => _cartItems.isEmpty;

  /// Cek apakah keranjang ada isinya
  bool get isNotEmpty => _cartItems.isNotEmpty;
}
