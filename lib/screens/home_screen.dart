import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:smart_kantin/services/auth_service.dart';
import '../models/products_model.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference _collectionProductshuda = FirebaseFirestore.instance
      .collection('products');

  final List<CartItem> _listCartItemshuda = [];
  String _strSelectedCategoryhuda = 'semua';

  void _handleAddToCartButtonhuda(ProductsModel product) {
    setState(() {
      final index = _listCartItemshuda.indexWhere(
        (item) => item.product.productId == product.productId,
      );

      if (index == -1) {
        _listCartItemshuda.add(CartItem(product: product, quantity: 1));
      } else {
        _listCartItemshuda[index].quantity++;
      }
    });
  String _selectedCategory = 'semua';

  void _addToCart(ProductsModel product) {
    final cartProvider = context.read<CartProvider>();
    cartProvider.addToCart(product, quantity: 1);

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
                  final cartProvider = context.read<CartProvider>();
                  Navigator.pushNamed(
                    context,
                    '/cart',
                    arguments: _listCartItemshuda,
                  );
                },
              ),
              if (_listCartItemshuda.isNotEmpty)
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
                      _listCartItemshuda.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                    arguments: cartProvider.cartItems,
                  );
                },
              ),
              Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  if (cartProvider.isEmpty) return const SizedBox.shrink();
                  return Positioned(
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
                        cartProvider.itemCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChiphuda('semua', 'Semua'),
                _buildCategoryChiphuda('makanan', 'Makanan'),
                _buildCategoryChiphuda('minuman', 'Minuman'),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _collectionProductshuda.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Belum ada produk.'));
                }

                List<DocumentSnapshot> docs = snapshot.data!.docs;

                if (_strSelectedCategoryhuda != 'semua') {
                  docs = docs
                      .where(
                        (doc) => doc['category']
                            .toString()
                            .toLowerCase()
                            .contains(_strSelectedCategoryhuda),
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
                      onAddToCart: () => _handleAddToCartButtonhuda(product),
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

  Widget _buildCategoryChiphuda(String value, String label) {
    final isSelected = _strSelectedCategoryhuda == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _strSelectedCategoryhuda = value;
          });
        },
        backgroundColor: Colors.transparent,
        selectedColor: const Color(0x332E79DB),
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
