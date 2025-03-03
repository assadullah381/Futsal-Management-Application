import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor:
            Color.fromARGB(255, 249, 249, 249), // Dark background for the app
        appBar: AppBar(
          title: Text('Futolo', style: TextStyle(color: Colors.white)),
          backgroundColor: Color.fromARGB(255, 3, 72, 23),
        ),
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
        body: ListView(
          children: [
            // Welcome Message with White Background
            Container(
              color: Colors.white, // White background for the welcome message
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Welcome to Futolo! 🌟\nConnect with your community, share moments, and explore turfs near you.',
                  style: TextStyle(
                    color: Color(0xFFC3F44D), // Dark text color
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
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
                  'C:/Users/shaheer/Desktop/FUTOLO/Futsal-Management-Application-1/assets/Maria Garcia.jpg', // Replace with your image path
              likes: 189,
              comments: 32,
            ),
            PostWidget(
              username: 'John Doe',
              imageUrl: 'assets/John Doe.jpg', // Replace with your image path
              likes: 312,
              comments: 67,
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xFF61D384),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Booking'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.people), label: 'Community'),
            BottomNavigationBarItem(
                icon: Icon(Icons.emoji_events), label: 'Ranking'),
          ],
        ),
      ),
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
        color: Color.fromARGB(255, 3, 72, 23), // Dark background for the post
        borderRadius: BorderRadius.circular(12), // Rounded corners
        border: Border.all(
            color: Color.fromARGB(255, 0, 0, 0), width: 2), // Dark green border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(0xFFC3F44D),
              child: Text(username[0], style: TextStyle(color: Colors.black)),
            ),
            title: Text(username, style: TextStyle(color: Colors.white)),
          ),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(12), // Rounded corners for the image
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.black,
                    width: 2), // Black border for the image
                borderRadius:
                    BorderRadius.circular(12), // Rounded corners for the image
              ),
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200, // Adjust height as needed
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
