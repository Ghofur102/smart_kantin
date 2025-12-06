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
  Map<String, dynamic> toMap_ghofur() {
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
    final data_ghofur = doc.data()!;

    return ProductsModel(
      productId: doc.id,
      name: data_ghofur['name'] ?? '',
      price: data_ghofur['price'] ?? 0,
      stock: data_ghofur['stock'] ?? 0,
      imageUrl: data_ghofur['imageUrl'] ?? '',
      category: Category.values.firstWhere(
        (e) => e.name == data_ghofur['category'],
        orElse: () => Category.makanan,
      ),
    );
  }

  static Future<void> seederProducts_ghofur() async {
    // Use debugPrint instead of print for better control in production/dev
    debugPrint("🔥🔥🔥 [START] MEMULAI FUNGSI SEEDER 🔥🔥🔥");
    final CollectionReference products_ghofur = FirebaseFirestore.instance.collection(
      'products',
    );

    final snapshot_ghofur = await products_ghofur.limit(1).get();

    if (snapshot_ghofur.docs.isNotEmpty) {
      return;
    }

    List<ProductsModel> dummyProducts_ghofur = [
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
    for (var product_ghofur in dummyProducts_ghofur) {
      await products_ghofur.add(
        product_ghofur.toMap_ghofur(),
      ); // firebase hanya mengerti data map makanya dikonversi pakai toMap()
      debugPrint("✅ Berhasil terkirim: ${product_ghofur.name}");
    }
  }
}

class CartItem {
  final ProductsModel product;
  double quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}
