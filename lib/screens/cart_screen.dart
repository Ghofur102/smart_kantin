import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/products_model.dart';
import '../services/auth_service.dart';
import '../themes/app_colors.dart';
import '../widgets/custom_button.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<CartItem> cartItems;
  double val_subtotal_zami = 0.0;
  double val_discount_zami = 0.0;
  double val_shipping_zami = 5000.0;
  double val_total_zami = 0.0;
  String? _nim_zami;
  bool _isLoading_zami = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cartItems = ModalRoute.of(context)!.settings.arguments as List<CartItem>;
    // load user NIM and recalculate totals
    _loadUserNimAndRecalc_zami();
  }

  void _updateQuantity(int index, double qty) {
    if (qty <= 0) {
      setState(() {
        cartItems.removeAt(index);
      });
    } else {
      setState(() {
        cartItems[index].quantity = qty;
      });
    }
  }

  int get _totalItems {
    return cartItems.fold(0, (sum, item) => sum + item.quantity.toInt());
  }

  // removed unused _totalPrice getter; subtotal is calculated with `val_subtotal_zami`

  Future<void> _loadUserNimAndRecalc_zami() async {
    final uid = await AuthService.instance.getLoggedInUserId();
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('nim')) {
          _nim_zami = data['nim']?.toString();
        }
      }
    }
    _recalculate_zami();
  }

  void _recalculate_zami() {
    val_subtotal_zami = cartItems.fold(0.0, (double sum, item) => sum + (item.product.price * item.quantity));

    // Default shipping fee (terserah tugas): Rp 5.000
    val_shipping_zami = 5000.0;
    val_discount_zami = 0.0;

    if (_nim_zami != null && _nim_zami!.isNotEmpty) {
      final digits = _nim_zami!.replaceAll(RegExp(r'\D'), '');
      if (digits.isNotEmpty) {
        final last = int.tryParse(digits[digits.length - 1]) ?? 0;
        if (last % 2 == 1) {
          // ganjil => diskon 5% pada subtotal
          val_discount_zami = val_subtotal_zami * 0.05;
          val_shipping_zami = 5000.0;
        } else {
          // genap => gratis ongkir
          val_discount_zami = 0.0;
          val_shipping_zami = 0.0;
        }
      }
    }

    val_total_zami = val_subtotal_zami - val_discount_zami + val_shipping_zami;
    if (mounted) setState(() {});
  }

  Future<void> _handlePayment_zami() async {
    setState(() {
      _isLoading_zami = true;
    });

    try {
      // Pastikan stok cukup dan jalankan transaksi pengurangan stok
      await checkoutAndReduceStock_zami(cartItems);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembayaran berhasil. Stok diperbarui.')),
      );

      // Kembalikan hasil true agar screen pemanggil tahu pembayaran selesai
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal bayar: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading_zami = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Saya'),
        centerTitle: true,
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Keranjang Kosong',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.product.name,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Rp ${item.product.price}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () =>
                                        _updateQuantity(index, item.quantity - 1),
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: AppColors.primary),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(Icons.remove,
                                          size: 16, color: AppColors.primary),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 32,
                                    child: Center(
                                      child: Text(
                                        '${item.quantity.toInt()}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () =>
                                        _updateQuantity(index, item.quantity + 1),
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(Icons.add,
                                          size: 16, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border:
                        Border(top: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Item:', style: TextStyle(fontSize: 14)),
                          Text('$_totalItems', key: const Key('txtTotalItem_zami'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          Text('Rp ${val_subtotal_zami.toStringAsFixed(2)}', key: const Key('txtSubtotal_zami'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Diskon (NIM):', style: TextStyle(fontSize: 14)),
                          Text('- Rp ${val_discount_zami.toStringAsFixed(2)}', key: const Key('txtDiscount_zami'), style: const TextStyle(fontSize: 14, color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Ongkir:', style: TextStyle(fontSize: 14)),
                          Text('Rp ${val_shipping_zami.toStringAsFixed(2)}', key: const Key('txtShipping_zami'), style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Rp ${val_total_zami.toStringAsFixed(2)}', key: const Key('txtTotal_zami'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        key: const Key('btnPembayaran_zami'),
                        label: _isLoading_zami ? 'Memproses...' : 'Pembayaran',
                        isLoading: _isLoading_zami,
                        onPressed: () async {
                          // Validasi stok dan jalankan transaksi
                          await _handlePayment_zami();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
