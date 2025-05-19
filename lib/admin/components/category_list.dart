import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class CategoryListScreen extends StatefulWidget {
  final Function(Map<String, dynamic>?) onAddOrEdit;

  const CategoryListScreen({Key? key, required this.onAddOrEdit})
      : super(key: key);

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final DatabaseReference _categoriesRef = FirebaseDatabase.instance.ref(
    'ecoActivities',
  );
  List<Map<String, dynamic>> _mainCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await _categoriesRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final categories = <Map<String, dynamic>>[];

        // Process personal category
        if (data['personal'] != null) {
          final personalData = data['personal'] as Map<dynamic, dynamic>;
          categories.add({
            'uid': personalData['uid'],
            'title': personalData['title'],
            'type': 'personal',
            'activities': _parseActivities(personalData['activities']),
          });
        }

        // Process community category
        if (data['community'] != null) {
          final communityData = data['community'] as Map<dynamic, dynamic>;
          categories.add({
            'uid': communityData['uid'],
            'title': communityData['title'],
            'type': 'community',
            'activities': _parseActivities(communityData['activities']),
          });
        }

        setState(() {
          _mainCategories = categories;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _parseActivities(dynamic activitiesData) {
    if (activitiesData == null || activitiesData is! Map) return [];

    return (activitiesData as Map<dynamic, dynamic>).entries.map((entry) {
      return {
        'uid': entry.value['uid'],
        'title': entry.value['title'] ?? 'Untitled',
        'points': entry.value['points'] ?? 10,
      };
    }).toList();
  }

  Future<void> _deleteActivity(String categoryType, String activityUid) async {
    setState(() => _isLoading = true);
    try {
      await _categoriesRef
          .child('$categoryType/activities/$activityUid')
          .remove();
      await _loadCategories();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete activity: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _mainCategories.isEmpty
              ? const Center(child: Text('No categories available'))
              : RefreshIndicator(
                  onRefresh: _loadCategories,
                  child: ListView(
                    children: _mainCategories.map((category) {
                      return ExpansionTile(
                        title: Text(category['title']),
                        children: (category['activities'] as List).map<Widget>((
                          activity,
                        ) {
                          return ListTile(
                            title: Text(activity['title']),
                            subtitle: Text(
                              'Points: ${activity['points']}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () => _deleteActivity(
                                category['type'],
                                activity['uid'],
                              ),
                            ),
                            onTap: () => widget.onAddOrEdit({
                              'uid': activity['uid'],
                              'title': activity['title'],
                              'points': activity['points'],
                              'type': category['type'],
                              'categoryTitle': category['title'],
                            }),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => widget.onAddOrEdit(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
