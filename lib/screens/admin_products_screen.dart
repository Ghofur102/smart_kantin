import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_kantin/services/product_service.dart';
import '../models/products_model.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CollectionReference firestoreProducts_ghofur = FirebaseFirestore
        .instance
        .collection('products');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Produk '),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/admin/product_form');
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: firestoreProducts_ghofur.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada produk"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final product = ProductsModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>);
              return Card(
                child: ListTile(
                  leading: Image.asset(
                    product.imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Icon(Icons.fastfood),
                  ),
                  title: Text(product.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Harga: Rp ${product.price}'),
                      Text('Stok: ${product.stock}'),
                      Text('Kategori: ${product.category.name}'),
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
                            arguments: product,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await ProductService().deleteProduct_ghofur(productId: product.productId);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}