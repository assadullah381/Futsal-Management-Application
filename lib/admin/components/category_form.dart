import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class CategoryFormScreen extends StatefulWidget {
  final Map<String, dynamic>? category;
  final VoidCallback onBack;

  const CategoryFormScreen({Key? key, this.category, required this.onBack})
      : super(key: key);

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final DatabaseReference _categoriesRef = FirebaseDatabase.instance.ref(
    'ecoActivities',
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  String? _categoryType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _titleController.text = widget.category!['title'] ?? '';
      _pointsController.text = (widget.category!['points'] ?? 10).toString();
      _categoryType = widget.category!['type'];
    } else {
      _pointsController.text = '10';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category type')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final categoryData = {
        'title': _titleController.text,
        'points': int.parse(_pointsController.text),
        'keywords': [_titleController.text.toLowerCase()],
      };

      if (widget.category == null) {
        // Add new category
        await _categoriesRef.child(_categoryType!).push().set(categoryData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category added successfully')),
        );
      } else {
        // Update existing category
        await _categoriesRef
            .child('${widget.category!['type']}/${widget.category!['key']}')
            .update(categoryData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category updated successfully')),
        );
      }

      widget.onBack();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving category: $e')));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
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
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                      ),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pointsController,
                      decoration: const InputDecoration(labelText: 'Points'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Required';
                        if (int.tryParse(value) == null)
                          return 'Invalid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Category Type'),
                        RadioListTile<String>(
                          title: const Text('Personal'),
                          value: 'personal',
                          groupValue: _categoryType,
                          onChanged: (value) =>
                              setState(() => _categoryType = value),
                        ),
                        RadioListTile<String>(
                          title: const Text('Community'),
                          value: 'community',
                          groupValue: _categoryType,
                          onChanged: (value) =>
                              setState(() => _categoryType = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Save Category'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
