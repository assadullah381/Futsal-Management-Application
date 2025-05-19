// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:manganuhu/admin/components/category_list.dart';
import 'package:manganuhu/admin/components/category_form.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({Key? key}) : super(key: key);

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  bool _showForm = false;
  Map<String, dynamic>? _categoryToEdit;

  void _toggleForm([Map<String, dynamic>? category]) {
    setState(() {
      _showForm = !_showForm;
      _categoryToEdit = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showForm
        ? CategoryFormScreen(
            category: _categoryToEdit,
            onBack: () => _toggleForm(),
          )
        : CategoryListScreen(onAddOrEdit: _toggleForm);
  }
}
