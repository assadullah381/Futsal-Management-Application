import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to the App!'),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/BookingPage');
              },
              child: const Text('Go to Booking Page'),
            ),
          ],
        ),
      ),
    );
  }
}
