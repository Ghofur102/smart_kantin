import 'package:flutter/material.dart';
import '../models/products_model.dart';
import '../themes/app_colors.dart';

class ProductCard extends StatelessWidget {
  final ProductsModel product;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: double.infinity,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  _getImagePath(product.name),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 24,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Product Name
            Text(
              product.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Category
            Text(
              product.category.name,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 4),

            // Price
            Text(
              'Rp ${product.price}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),

            // Stock Info
            Text(
              'Stok: ${product.stock}',
              style: const TextStyle(fontSize: 9, color: Colors.grey),
            ),
            const SizedBox(height: 6),

            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              height: 28,
              child: ElevatedButton(
                onPressed: product.stock > 0 ? onAddToCart : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'Tambah',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Convert product name to asset image path
  /// E.g. "mie ayam" -> "assets/images/mie ayam.png"
  String _getImagePath(String productName) {
    // Mapping nama produk ke nama file gambar
    final imageMap = {
      'mie ayam': 'assets/images/mie ayam.png',
      'mie nyemek': 'assets/images/mie nyemek.png',
      'mie kuah': 'assets/images/mie kuah.png',
      'mie goreng': 'assets/images/mie goreng.png',
      'es teh': 'assets/images/es teh.png',
      'es jeruk': 'assets/images/es jeruk.png',
      'es marimas': 'assets/images/es marimas.png',
      'pop ice': 'assets/images/pop ice.png',
      'nasi goreng': 'assets/images/nasi goreng.jpg',
      'ayam goreng': 'assets/images/ayam goreng.png',
    };

    // Return mapping jika ada, jika tidak ada return default placeholder
    return imageMap[productName.toLowerCase()] ??
        'assets/images/nasi goreng.jpg';
  }
}
