import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/products_model.dart';
import '../models/transactions_model.dart';

/// Service untuk mengelola transaksi checkout
class TransactionsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fungsi untuk mengurangi stok produk saat checkout.
  /// Menggunakan Firestore transaction untuk memastikan konsistensi data.
  /// Semua operasi read dilakukan terlebih dahulu, kemudian operasi write.
  static Future<void> checkoutAndReduceStock_zami(List<CartItem> items) async {
    final CollectionReference products = _firestore.collection('products');

    await _firestore.runTransaction((transaction) async {
      // Phase 1: Baca semua dokumen dan validasi stok
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

      // Phase 2: Lakukan semua update stok
      for (final u in updates) {
        final docRef = u['docRef'] as DocumentReference;
        final newStock = u['newStock'] as int;
        transaction.update(docRef, {'stock': newStock});
      }
    });
  }

  /// Fungsi untuk membuat dan menyimpan transaksi ke Firestore.
  /// Setelah transaksi berhasil disimpan, stok produk akan berkurang.
  static Future<String> createTransactions_zami({
    required String userId,
    required int totalFinal,
    required List<CartItem> items,
    required Status status,
  }) async {
    try {
      // Pastikan stok cukup terlebih dahulu sebelum membuat transaksi
      await checkoutAndReduceStock_zami(items);

      // Jika stok cukup, buat data transaksi
      final transactionData = {
        'userId': userId,
        'totalFinal': totalFinal,
        'status': status.toString().split('.').last, // Convert enum ke string (pending/success)
        'items': items
            .map((item) => {
                  'productId': item.product.productId,
                  'name': item.product.name,
                  'price': item.product.price,
                  'quantity': item.quantity,
                  'stock': item.product.stock,
                })
            .toList(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Simpan transaksi ke Firestore
      final docRef =
          await _firestore.collection('transactions').add(transactionData);

      return docRef.id; // Return transaction ID
    } catch (e) {
      // Jika ada error, lempar exception dengan pesan yang jelas
      throw Exception('Gagal membuat transaksi: ${e.toString()}');
    }
  }
}
