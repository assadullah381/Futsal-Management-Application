import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:manganuhu/models/post_model.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final DatabaseReference _postsRef = FirebaseDatabase.instance.ref('posts');
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');
  final DatabaseReference _ecoActivitiesRef = FirebaseDatabase.instance.ref(
    'ecoActivities',
  );
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  String _imageBase64 = "";
  String _selectedCategory = 'None';
  String _selectedSubCategory = 'None';
  Map<String, List<String>> _categories = {
    'None': ['None'],
  };
  bool _isLoadingCategories = true;
  int _subCategoryPoints = 0;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final snapshot = await _ecoActivitiesRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final categories = <String, List<String>>{
          'None': ['None'],
        };

        data.forEach((categoryKey, categoryData) {
          if (categoryData is Map && categoryData['activities'] is Map) {
            final activities =
                categoryData['activities'] as Map<dynamic, dynamic>;
            final subCategories = activities.values
                .whereType<Map>()
                .map<String>((activity) => activity['title'].toString())
                .toList();

            categories[categoryKey.toString()] = subCategories;
          }
        });

        setState(() {
          _categories = categories;
          _selectedCategory = 'None';
          _selectedSubCategory = 'None';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<int> _getSubCategoryPoints(String category, String subCategory) async {
    if (category == 'None' || subCategory == 'None') return 0;

    try {
      final snapshot =
          await _ecoActivitiesRef.child('$category/activities').get();

      if (snapshot.exists) {
        final activities = snapshot.value as Map<dynamic, dynamic>;
        for (final activity in activities.values) {
          if (activity is Map && activity['title'] == subCategory) {
            return (activity['points'] as num?)?.toInt() ?? 0;
          }
        }
      }
      return 0;
    } catch (e) {
      debugPrint('Error getting points: $e');
      return 0;
    }
  }

  Future<void> _updateUserPoints(String userId, int points) async {
    if (points <= 0) return;

    try {
      await _usersRef.child(userId).child('pointsEarned').runTransaction((
        mutableData,
      ) {
        final currentPoints = (mutableData as num?)?.toInt() ?? 0;
        return Transaction.success(currentPoints + points);
      });
    } catch (e) {
      debugPrint('Error updating points: $e');
      rethrow;
    }
  }

  Future<void> _createPost() async {
    if (contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some content')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isPosting = true);

    try {
      // Get points for selected activity
      _subCategoryPoints = await _getSubCategoryPoints(
        _selectedCategory,
        _selectedSubCategory,
      );

      // Create post
      final newPostRef = _postsRef.push();
      final newPost = Post(
        id: newPostRef.key!,
        userId: user.uid,
        userName: user.displayName ?? 'Anonymous',
        userAvatarUrl: user.photoURL,
        subject: subjectController.text,
        content: contentController.text,
        isPublic: true,
        timestamp: DateTime.now(),
        imageBase64: _imageBase64.isNotEmpty ? _imageBase64 : null,
        category: _selectedCategory == 'None' ? null : _selectedCategory,
        subCategory:
            _selectedSubCategory == 'None' ? null : _selectedSubCategory,
        pointsEarned: _subCategoryPoints,
      );

      await newPostRef.set(newPost.toMap());

      // Update user points if earned any
      if (_subCategoryPoints > 0) {
        await _updateUserPoints(user.uid, _subCategoryPoints);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _subCategoryPoints > 0
                  ? 'Post created! +${_subCategoryPoints} points earned!'
                  : 'Post created successfully',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create post: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final bytes = await File(image.path).readAsBytes();
    setState(() {
      _selectedImage = File(image.path);
      _imageBase64 = base64Encode(bytes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          if (_isPosting)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Category Selection
            _isLoadingCategories
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration:
                            const InputDecoration(labelText: 'Category'),
                        items: _categories.keys
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                            _selectedSubCategory = _categories[value]!.first;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedSubCategory,
                        decoration:
                            const InputDecoration(labelText: 'Activity'),
                        items: _categories[_selectedCategory]!
                            .map(
                              (sub) => DropdownMenuItem(
                                value: sub,
                                child: Text(sub),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedSubCategory = value!),
                      ),
                      if (_selectedCategory != 'None')
                        FutureBuilder<int>(
                          future: _getSubCategoryPoints(
                            _selectedCategory,
                            _selectedSubCategory,
                          ),
                          builder: (context, snapshot) {
                            final points = snapshot.data ?? 0;
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: points > 0
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        children: [
                                          Icon(Icons.star, color: Colors.amber),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Earns $points points',
                                            style: TextStyle(
                                              color: Colors.green[700],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            );
                          },
                        ),
                    ],
                  ),

            const SizedBox(height: 24),

            // Post Content
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
                hintText: 'Share your experience...',
              ),
              maxLines: 5,
            ),

            const SizedBox(height: 24),

            // Image Preview
            if (_selectedImage != null)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() {
                      _selectedImage = null;
                      _imageBase64 = "";
                    }),
                    child: const Text('Remove Image'),
                  ),
                ],
              ),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('Add Image'),
                    onPressed: _pickImage,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _isPosting ? null : _createPost,
                    child: const Text('Post'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
