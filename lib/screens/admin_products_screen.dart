import 'package:flutter/material.dart';
import '../models/products_model.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Produk - huda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/admin/product_form');
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _dummyProducts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final p = _dummyProducts[i];
          return Card(
            child: ListTile(
              leading: Image.asset(
                p.imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const Icon(Icons.fastfood),
              ),
              title: Text(p.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Harga: Rp ${p.price}'),
                  Text('Stok: ${p.stock}'),
                  Text('Kategori: ${p.category.name}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/admin/product_form',
                        arguments: p,
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {}, // hanya tampilan
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Dummy data produk untuk tampilan saja
  List<ProductsModel> get _dummyProducts => [
    ProductsModel(
      productId: '1',
      name: 'Mie Ayam',
      price: 12000,
      stock: 10,
      imageUrl: 'assets/images/mie ayam.png',
      category: Category.makanan,
    ),
    ProductsModel(
      productId: '2',
      name: 'Es Teh',
      price: 3000,
      stock: 20,
      imageUrl: 'assets/images/es teh.png',
      category: Category.minuman,
    ),
  ];
}
