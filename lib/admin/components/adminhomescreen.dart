import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manganuhu/authentication/login.dart';
import 'package:manganuhu/admin/components/product_management.dart';
import 'package:manganuhu/admin/components/category_management.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  bool _isAdmin = false;
  bool _isLoading = true;
  bool _hasAdminCheckCompleted = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    if (_currentUser == null) {
      await _logout();
      return;
    }

    try {
      final adminRef = FirebaseDatabase.instance.ref('admins');
      final snapshot = await adminRef.child(_currentUser!.uid).get();

      if (mounted) {
        setState(() {
          _isAdmin = snapshot.exists;
          _hasAdminCheckCompleted = true;
          _isLoading = false;
        });
      }

      if (!snapshot.exists) {
        await _logout();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasAdminCheckCompleted = true;
          _isLoading = false;
        });
      }
      await _logout();
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasAdminCheckCompleted) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isAdmin) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Access Denied', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
              const Text('You do not have admin privileges'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _logout,
                child: const Text('Return to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _currentIndex,
              children: const [
                ProductManagementScreen(),
                CategoryManagementScreen(),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
        ],
      ),
    );
  }
}
