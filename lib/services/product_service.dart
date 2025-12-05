import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_kantin/models/products_model.dart';

class ProductService {
    final FirebaseFirestore _firestore_ghofur = FirebaseFirestore.instance;

    Future<void> createProduct_ghofur({
      required String name,
      required int price,
      required int stock,
      required String imageUrl,
      required Category category,
    }) async {
      try {
        final productId_ghofur = 'productId-$name-${DateTime.now().millisecondsSinceEpoch}';
        final product_ghofur = ProductsModel(productId: productId_ghofur, name: name, price: price, stock: stock, imageUrl: imageUrl, category: category);
        await _firestore_ghofur.collection('products').doc(productId_ghofur).set(product_ghofur.toMap_ghofur());
      } catch (e) {
        throw Exception(e.toString());
      }
    }

    Future<void> updateProduct_ghofur({
      required String productId,
      required String name,
      required int price,
      required int stock,
      required String imageUrl,
      required Category category,
    }) async {
      try {
        final product_ghofur = ProductsModel(productId: productId, name: name, price: price, stock: stock, imageUrl: imageUrl, category: category);
        await _firestore_ghofur.collection('products').doc(productId).update(product_ghofur.toMap_ghofur());
      } catch (e) {
        throw Exception(e.toString());
      }
    }

    Future<void> deleteProduct_ghofur({
      required String productId,
    }) async {
      try {
        await _firestore_ghofur.collection('products').doc(productId).delete();
      } catch (e) {
        throw Exception(e.toString());
      }
    } 

}