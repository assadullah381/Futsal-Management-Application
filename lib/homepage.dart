import 'package:flutter/material.dart';
import 'booking_page.dart';
import 'selectfield_page.dart';
import 'post.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:appwrite/appwrite.dart';
import 'comment_screen.dart';
import 'login.dart';
import 'signup.dart';
import 'choicecard.dart';
import 'gettingstarted.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(),
      routes: {
        '/BookingPage': (context) => BookingPage(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2;
  late Client clients;

  @override
  void initState() {
    super.initState();
    clients = Client();
    clients.setProject('67d0e2dd00399b43677c');
  }

  // final List<Widget> _screens = [
  //   BookingPage(),
  //   Text("Chat Page"),
  //   SelectFieldPage(),
  //   Text("Community Page"),
  //   Text("Ranking Page"),
  // ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xFF1A434E), // Dark background for the app

        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF61D384)),
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person, color: Color(0xFF61D384)),
                title: Text('Profile',
                    style:
                        TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.sports_soccer, color: Color(0xFF61D384)),
                title: Text('Turfs',
                    style: TextStyle(
                        color: const Color.fromARGB(0, 255, 255, 255))),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.store, color: Color(0xFF61D384)),
                title: Text('Store',
                    style: TextStyle(
                        color: const Color.fromARGB(0, 255, 255, 255))),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.notifications, color: Color(0xFF61D384)),
                title: Text('Notifications',
                    style: TextStyle(
                        color: const Color.fromARGB(0, 255, 255, 255))),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.privacy_tip, color: Color(0xFF61D384)),
                title: Text('Privacy Policy',
                    style: TextStyle(
                        color: const Color.fromARGB(0, 255, 255, 255))),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.settings, color: Color(0xFF61D384)),
                title: Text('Settings',
                    style: TextStyle(
                        color: const Color.fromARGB(0, 255, 255, 255))),
                onTap: () {},
              ),
            ],
          ),
        ),
        body: _selectedIndex == 0
            ? SelectFieldPage()
            : ListView(
                children: [
                  // Example Posts
                  PostWidget(
                    username: 'Alex Johnson',
                    imageUrl:
                        'assets/Alex Johnson.jpg', // Replace with your image path
                    likes: 256,
                    comments: 45,
                  ),
                  PostWidget(
                    username: 'Maria Garcia',
                    imageUrl:
                        'assets/Maria Garcia.jpg', // Replace with your image path
                    likes: 189,
                    comments: 32,
                  ),
                  PostWidget(
                    username: 'John Doe',
                    imageUrl:
                        'assets/John Doe.jpg', // Replace with your image path
                    likes: 312,
                    comments: 67,
                  ),
                ],
              ),
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Color(0xFF1A434E), // Background of screen
          color: Colors.black, // Bar color
          buttonBackgroundColor: Color(0xFF61D384), // Highlighted item color
          height: 60,
          animationDuration: Duration(milliseconds: 300),
          index: _selectedIndex,
          items: [
            Icon(Icons.book, color: Colors.white),
            Icon(Icons.chat, color: Colors.white),
            Icon(Icons.home, color: Colors.white),
            Icon(Icons.people, color: Colors.white),
            Icon(Icons.emoji_events, color: Colors.white),
          ],
          onTap: _onItemTapped,
        ),
      ),
      routes: {
        '/BookingPage': (context) => BookingPage(),
      },
    );
  }
}
