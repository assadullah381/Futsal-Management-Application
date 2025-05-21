import 'package:flutter/material.dart' hide Card;
import 'package:flutter/material.dart' as material;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'post/FullScreenImageView.dart';
import 'screens/cartscreen.dart';
import 'dart:convert';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final DatabaseReference _marketplaceRef = FirebaseDatabase.instance.ref(
    'marketplace',
  );
  List<Map<dynamic, dynamic>> _products = [];
  List<Map<dynamic, dynamic>> _cartItems = [];
  bool _isLoading = true;
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);

    try {
      _marketplaceRef.orderByChild('createdAt').onValue.listen((event) {
        if (event.snapshot.value != null) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          final loadedProducts = data.entries.map((entry) {
            return {'id': entry.key, ...entry.value};
          }).toList();

          loadedProducts.sort(
            (a, b) => (b['createdAt'] ?? 0).compareTo(a['createdAt'] ?? 0),
          );

          setState(() {
            _products = loadedProducts;
            _isLoading = false;
          });
        } else {
          setState(() {
            _products = [];
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading products: $e')));
    }
  }

  void _addToCart(Map<dynamic, dynamic> product) {
    setState(() {
      final existingIndex = _cartItems.indexWhere(
        (item) => item['id'] == product['id'],
      );
      if (existingIndex >= 0) {
        _cartItems[existingIndex]['quantity'] += 1;
      } else {
        _cartItems.add({...product, 'quantity': 1});
      }
      _calculateTotal();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product['title']} added to cart')),
    );
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
      _calculateTotal();
    });
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity > 0) {
      setState(() {
        _cartItems[index]['quantity'] = newQuantity;
        _calculateTotal();
      });
    } else if (newQuantity == 0) {
      _removeFromCart(index);
    }
  }

  void _calculateTotal() {
    _totalAmount = _cartItems.fold(0.0, (sum, item) {
      return sum + (item['price'] * item['quantity']);
    });
  }

  void _handleCartUpdate() {
    setState(() {
      // Forces a rebuild to update the UI
    });
  }

  Widget _buildProductCard(Map<dynamic, dynamic> product) {
    final images =
        product['images'] is List ? List<String>.from(product['images']) : [];

    return material.Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (images.isNotEmpty)
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, imgIndex) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImageView(
                            imageFile: MemoryImage(
                              base64Decode(images[imgIndex]),
                            ),
                            onClose: () => Navigator.pop(context),
                          ),
                        ),
                      );
                    },
                    child: Image.memory(
                      base64Decode(images[imgIndex]),
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['title'] ?? 'No Title',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(product['description'] ?? 'No Description'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${product['price']?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Available: ${product['quantity'] ?? 0}'),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _addToCart(product),
                  child: const Text('Add to Cart'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartScreen(
                        cartItems: _cartItems,
                        updateQuantity: _updateQuantity,
                        removeFromCart: _removeFromCart,
                        totalAmount: _totalAmount,
                        onCartUpdated: _handleCartUpdate,
                      ),
                    ),
                  ).then((_) {
                    // This ensures the UI updates when returning from CartScreen
                    setState(() {});
                  });
                },
              ),
              if (_cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _cartItems
                          .fold<int>(
                            0,
                            (sum, item) => sum + (item['quantity'] as int),
                          )
                          .toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(child: Text('No products available'))
              : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) =>
                      _buildProductCard(_products[index]),
                ),
    );
  }
}
