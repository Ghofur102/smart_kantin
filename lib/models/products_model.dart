import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum Category { makanan, minuman }

class ProductsModel {
  final String productId;
  final String name;
  final int price;
  final int stock;
  final String imageUrl;
  final Category category;

  ProductsModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.category,
  });

  // konversi dari object dart ke map untuk dikirim ke firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'category': category.name,
    };
  }

  // konversi dari map ke object dart untuk ditampilkan di flutter dari firebase
  factory ProductsModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return ProductsModel(
      productId: doc.id,
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      stock: data['stock'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      category: Category.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => Category.makanan,
      ),
    );
  }

  static Future<void> seederProducts() async {
    // Use debugPrint instead of print for better control in production/dev
    debugPrint("🔥🔥🔥 [START] MEMULAI FUNGSI SEEDER 🔥🔥🔥");
    final CollectionReference products = FirebaseFirestore.instance.collection(
      'products',
    );

    final snapshot = await products.limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      return;
    }

    List<ProductsModel> dummyProducts = [
      ProductsModel(
        productId: "",
        name: "mie ayam",
        price: 12000,
        stock: 100,
        imageUrl: "assets/images/mie ayam.png",
        category: Category.makanan,
      ),
      ProductsModel(
        productId: "",
        name: "mie nyemek",
        price: 10000,
        stock: 100,
        imageUrl: "assets/images/mie nyemek.png",
        category: Category.makanan,
      ),
      ProductsModel(
        productId: "",
        name: "mie kuah",
        price: 8000,
        stock: 100,
        imageUrl: "assets/images/mie kuah.png",
        category: Category.makanan,
      ),
      ProductsModel(
        productId: "",
        name: "mie goreng",
        price: 8000,
        stock: 100,
        imageUrl: "assets/images/mie goreng.png",
        category: Category.makanan,
      ),
      ProductsModel(
        productId: "",
        name: "es teh",
        price: 3000,
        stock: 100,
        imageUrl: "assets/images/es teh.png",
        category: Category.minuman,
      ),
      ProductsModel(
        productId: "",
        name: "es jeruk",
        price: 12000,
        stock: 100,
        imageUrl: "assets/images/es jeruk.png",
        category: Category.minuman,
      ),
      ProductsModel(
        productId: "",
        name: "es marimas",
        price: 2000,
        stock: 100,
        imageUrl: "assets/images/es marimas.png",
        category: Category.minuman,
      ),
      ProductsModel(
        productId: "",
        name: "pop ice",
        price: 5000,
        stock: 100,
        imageUrl: "assets/images/pop ice.png",
        category: Category.minuman,
      ),
      ProductsModel(
        productId: "",
        name: "nasi goreng",
        price: 12000,
        stock: 100,
        imageUrl: "assets/images/nasi goreng.jpg",
        category: Category.makanan,
      ),
      ProductsModel(
        productId: "",
        name: "ayam goreng",
        price: 12000,
        stock: 100,
        imageUrl: "assets/images/ayam goreng.png",
        category: Category.makanan,
      ),
    ];
    for (var product in dummyProducts) {
      await products.add(
        product.toMap(),
      ); // firebase hanya mengerti data map makanya dikonversi pakai toMap()
      debugPrint("✅ Berhasil terkirim: ${product.name}");
    }
  }
}

class CartItem {
  final ProductsModel product;
  double quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}

/// Jalankan transaksi Firestore untuk mengurangi stok produk saat checkout.
/// Nama fungsi diakhiri dengan inisial sesuai aturan tugas.
Future<void> checkoutAndReduceStock_zami(List<CartItem> items) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference products = firestore.collection('products');

  await firestore.runTransaction((transaction) async {
    // First, perform ALL reads for the transaction
    final List<Map<String, dynamic>> updates = [];

    for (final item in items) {
      final docRef = products.doc(item.product.productId);
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw Exception('Produk tidak ditemukan: ${item.product.name}');
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final int stock = (data['stock'] ?? 0) as int;
      final int requested = item.quantity.toInt();

      if (stock < requested) {
        throw Exception('Stok tidak cukup untuk ${item.product.name}');
      }

      final int newStock = stock - requested;
      updates.add({'docRef': docRef, 'newStock': newStock});
    }

    // Then perform all writes
    for (final u in updates) {
      final docRef = u['docRef'] as DocumentReference;
      final newStock = u['newStock'] as int;
      transaction.update(docRef, {'stock': newStock});
    }
  });
}
