import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/products_model.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference _products = FirebaseFirestore.instance.collection(
    'products',
  );

  List<ProductsModel> _cartItems = [];
  String _selectedCategory = 'semua';

  void _addToCart(ProductsModel product) {
    setState(() {
      final existingIndex = _cartItems.indexWhere(
        (item) => item.productId == product.productId,
      );

      if (existingIndex == -1) {
        _cartItems.add(product);
      } else {
        if (_cartItems[existingIndex].stock > 0) {
          _cartItems[existingIndex] = ProductsModel(
            productId: _cartItems[existingIndex].productId,
            name: _cartItems[existingIndex].name,
            price: _cartItems[existingIndex].price,
            stock: _cartItems[existingIndex].stock + 1,
            imageUrl: _cartItems[existingIndex].imageUrl,
            category: _cartItems[existingIndex].category,
          );
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} ditambahkan ke keranjang')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Kantin'),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.pushNamed(context, '/cart', arguments: _cartItems);
                },
              ),
              if (_cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      _cartItems.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip('semua', 'Semua'),
                _buildCategoryChip('makanan', 'Makanan'),
                _buildCategoryChip('minuman', 'Minuman'),
              ],
            ),
          ),

          // Products Grid
          Expanded(
            child: StreamBuilder(
              stream: _products.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Belum ada produk.'));
                }

                List<DocumentSnapshot> docs = snapshot.data!.docs;

                // Filter by category
                if (_selectedCategory != 'semua') {
                  docs = docs
                      .where(
                        (doc) =>
                            doc['category'].toString().toLowerCase() ==
                            _selectedCategory,
                      )
                      .toList();
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot document = docs[index];
                    final product = ProductsModel.fromSnapshot(
                      document as DocumentSnapshot<Map<String, dynamic>>,
                    );

                    return ProductCard(
                      product: product,
                      onAddToCart: () => _addToCart(product),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String value, String label) {
    final isSelected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = value;
          });
        },
        backgroundColor: Colors.transparent,
        selectedColor: const Color(0xFF2E79DB).withOpacity(0.2),
        side: BorderSide(
          color: isSelected ? const Color(0xFF2E79DB) : Colors.grey,
        ),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF2E79DB) : Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
