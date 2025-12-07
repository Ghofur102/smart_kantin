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
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            SizedBox(
              width: double.infinity,
              height: 135,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 32,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Product Name
            Flexible(
              child: Text(
                product.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),

            // Category
            Text(
              product.category.name,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 2),

            // Price
            Text(
              'Rp ${product.price}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 2),

            // Stock Info
            Text(
              'Stok: ${product.stock}',
              style: const TextStyle(fontSize: 9, color: Colors.grey),
            ),
            const SizedBox(height: 4),

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
}