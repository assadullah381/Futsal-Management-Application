import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manganuhu/post/FullScreenImageView.dart';

class ProductFormScreen extends StatefulWidget {
  final Map<String, dynamic>? product;
  final VoidCallback onBack;

  const ProductFormScreen({Key? key, this.product, required this.onBack})
      : super(key: key);

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final DatabaseReference _marketplaceRef = FirebaseDatabase.instance.ref(
    'marketplace',
  );
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  List<String> _imageBase64List = [];
  bool _isLoading = false;
  static const List<String> productCategories = [
    'Home & Kitchen',
    'Fashion',
    'Beauty & Wellness',
    'Food & Beverage',
    'Outdoor & Recreation',
    'Zero Waste',
    'Gifts & Stationery',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _titleController.text = widget.product!['title'] ?? '';
      _descriptionController.text = widget.product!['description'] ?? '';
      _priceController.text = (widget.product!['price'] ?? 0).toString();
      _quantityController.text = (widget.product!['quantity'] ?? 0).toString();
      _categoryController.text = widget.product!['category'] ?? '';

      if (widget.product!['images'] is List) {
        _imageBase64List = List<String>.from(widget.product!['images']);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedFiles.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        final newImages = await Future.wait(
          pickedFiles.map((file) async {
            final bytes = await file.readAsBytes();
            return base64Encode(bytes);
          }),
        );

        setState(() {
          _imageBase64List.addAll(newImages);
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error processing images: $e')));
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageBase64List.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final productData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'quantity': int.parse(_quantityController.text),
        'category': _categoryController.text,
        'images': _imageBase64List,
        'updatedAt': ServerValue.timestamp,
        'createdBy': _currentUser?.uid,
      };

      if (widget.product == null) {
        // Add new product
        productData['createdAt'] = ServerValue.timestamp;
        await _marketplaceRef.push().set(productData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );
      } else {
        // Update existing product
        await _marketplaceRef.child(widget.product!['id']).update(productData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully')),
        );
      }

      widget.onBack();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving product: $e')));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Price',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) return 'Required';
                              if (double.tryParse(value) == null)
                                return 'Invalid number';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) return 'Required';
                              if (int.tryParse(value) == null)
                                return 'Invalid number';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _categoryController.text.isEmpty
                          ? null
                          : _categoryController.text,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                      items: productCategories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      validator: (value) =>
                          value == null ? 'Please select a category' : null,
                      onChanged: (String? newValue) {
                        setState(() {
                          _categoryController.text = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.image),
                      label: const Text('Add Images'),
                    ),
                    const SizedBox(height: 8),
                    if (_imageBase64List.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_imageBase64List.length} image(s) selected',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _imageBase64List.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FullScreenImageView(
                                          imageFile: MemoryImage(
                                            base64Decode(
                                              _imageBase64List[index],
                                            ),
                                          ),
                                          onClose: () => Navigator.pop(context),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Image.memory(
                                          base64Decode(
                                            _imageBase64List[index],
                                          ),
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _imageBase64List.removeAt(
                                                index,
                                              );
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Save Product'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
