import 'package:cloud_firestore/cloud_firestore.dart';

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
        (e) => e.name == data['category'], orElse: () => Category.makanan,
      ),
    );
  }

  static Future<void> seederProducts() async {
    print("🔥🔥🔥 [START] MEMULAI FUNGSI SEEDER 🔥🔥🔥");
    final CollectionReference products = FirebaseFirestore.instance.collection(
      'products',
    );

    final snapshot = await products.limit(1).get();

    if(snapshot.docs.isNotEmpty) {
      return;
    }

    List<ProductsModel> dummyProducts = [
      ProductsModel(
        productId: "",
        name: "mie ayam",
        price: 12000,
        stock: 100,
        imageUrl: "gambarmieayam.png",
        category: Category.makanan,
      ),
      ProductsModel(
        productId: "",
        name: "mie nyemek",
        price: 10000,
        stock: 100,
        imageUrl: "mienyemek.png",
        category: Category.makanan,
      ),
      ProductsModel(
        productId: "",
        name: "mie kuah",
        price: 8000,
        stock: 100,
        imageUrl: "gambarmiekuah.png",
        category: Category.makanan,
      ),
      ProductsModel(
        productId: "",
        name: "mie goreng",
        price: 8000,
        stock: 100,
        imageUrl: "gambarmiegoreng.png",
        category: Category.makanan,
      ),
      ProductsModel(
        productId: "",
        name: "es teh",
        price: 3000,
        stock: 100,
        imageUrl: "gambaresteh.png",
        category: Category.minuman,
      ),
      ProductsModel(
        productId: "",
        name: "es jeruk",
        price: 12000,
        stock: 100,
        imageUrl: "gambahesjeruk.png",
        category: Category.minuman,
      ),
      ProductsModel(
        productId: "",
        name: "es marimas",
        price: 2000,
        stock: 100,
        imageUrl: "gambaresmarimas.png",
        category: Category.minuman,
      ),
      ProductsModel(
        productId: "",
        name: "pop ice",
        price: 5000,
        stock: 100,
        imageUrl: "gambarpopice.png",
        category: Category.minuman,
      ),
      ProductsModel(
        productId: "",
        name: "nasi goreng",
        price: 12000,
        stock: 100,
        imageUrl: "gambarnasigoreng.png",
        category: Category.makanan,
      ),
      ProductsModel(
        productId: "",
        name: "ayam goreng",
        price: 12000,
        stock: 100,
        imageUrl: "gambarayamgoreng.png",
        category: Category.makanan,
      ),
    ];
    for (var product in dummyProducts) {
      await products.add(product.toMap()); // firebase hanya mengerti data map makanya dikonversi pakai toMap() 
      print("✅ Berhasil terkirim!");
    }
  }

}

class CartItem {
  final ProductsModel product;
  double quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}
