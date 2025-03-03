import 'package:flutter/material.dart';
import 'booking_page.dart';
import 'selectfield_page.dart'; // Import the SelectFieldPage
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 2;

  final List<Widget> _screens = [
    BookingPage(),
    Text("Chat Page"),
    SelectFieldPage(),
    Text("Community Page"),
    Text("Ranking Page"),
  ];

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

class PostWidget extends StatelessWidget {
  final String username;
  final String imageUrl;
  final int likes;
  final int comments;

  const PostWidget({
    required this.username,
    required this.imageUrl,
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color(0xFF61D384), // Dark background for the post
        borderRadius: BorderRadius.circular(12), // Rounded corners
        border: Border.all(width: 2), // Dark green border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(0xFFC3F44D),
              child: Text(username[0], style: TextStyle(color: Colors.black)),
            ),
            title: Text(username, style: TextStyle(color: Color(0xFF1A434E))),
          ),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(12), // Rounded corners for the image
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 2), // Black border for the image
                borderRadius:
                    BorderRadius.circular(12), // Rounded corners for the image
              ),
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity, // Adjust width as needed
                height: 350, // Adjust height as needed
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(Icons.favorite, color: Colors.red),
                SizedBox(width: 4),
                Text('$likes likes', style: TextStyle(color: Colors.white)),
                SizedBox(width: 16),
                Icon(Icons.comment, color: Color(0xFF61D384)),
                SizedBox(width: 4),
                Text('$comments comments',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
