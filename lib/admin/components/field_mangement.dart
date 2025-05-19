// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:manganuhu/admin/components/product_list.dart';
import 'package:manganuhu/admin/components/product_form.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({Key? key}) : super(key: key);

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  bool _showForm = false;
  Map<String, dynamic>? _productToEdit;

  void _toggleForm([Map<String, dynamic>? product]) {
    setState(() {
      _showForm = !_showForm;
      _productToEdit = product;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showForm
        ? ProductFormScreen(
            product: _productToEdit,
            onBack: () => _toggleForm(),
          )
        : ProductListScreen(onAddOrEdit: _toggleForm);
  }
}
