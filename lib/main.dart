import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:futolo/homepage.dart';

import 'booking_page.dart';
import 'login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Client client = Client();
  late Account account;
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initializeAppwrite();
  }

  Future<void> _initializeAppwrite() async {
    client
        .setEndpoint(
            'https://cloud.appwrite.io/v1') // replace with your endpoint
        .setProject('67d0e2dd00399b43677c'); // your project ID

    account = Account(client);

    try {
      final models.Session session =
          await account.getSession(sessionId: 'current');
      setState(() {
        _isLoggedIn = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator(color: Colors.green)),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _isLoggedIn ? const HomePage() : const LoginPage(),
      routes: {
        '/BookingPage': (context) => BookingPage(),
        // Add other routes here
      },
    );
  }
}
