import 'package:flutter/material.dart';
import 'booking_page.dart';
import 'selectfield_page.dart';
import 'comment_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:appwrite/appwrite.dart';

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
  late Client client;

  @override
  void initState() {
    super.initState();
    client = Client();
    client.setProject('67d0e2dd00399b43677c');
  }

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
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E), // Dark background

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF61D384)),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF61D384)),
              title:
                  const Text('Profile', style: TextStyle(color: Colors.black)),
              onTap: () {},
            ),
            ListTile(
              leading:
                  const Icon(Icons.sports_soccer, color: Color(0xFF61D384)),
              title: const Text('Turfs', style: TextStyle(color: Colors.black)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.store, color: Color(0xFF61D384)),
              title: const Text('Store', style: TextStyle(color: Colors.black)),
              onTap: () {},
            ),
            ListTile(
              leading:
                  const Icon(Icons.notifications, color: Color(0xFF61D384)),
              title: const Text('Notifications',
                  style: TextStyle(color: Colors.black)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip, color: Color(0xFF61D384)),
              title: const Text('Privacy Policy',
                  style: TextStyle(color: Colors.black)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF61D384)),
              title:
                  const Text('Settings', style: TextStyle(color: Colors.black)),
              onTap: () {},
            ),
          ],
        ),
      ),

      body: _screens[_selectedIndex],

      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: const Color(0xFF1A434E), // Background of screen
        color: Colors.black, // Bar color
        buttonBackgroundColor:
            const Color(0xFF61D384), // Highlighted item color
        height: 60,
        animationDuration: const Duration(milliseconds: 300),
        index: _selectedIndex,
        items: const [
          Icon(Icons.book, color: Colors.white),
          Icon(Icons.chat, color: Colors.white),
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.people, color: Colors.white),
          Icon(Icons.emoji_events, color: Colors.white),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}

class PostWidget extends StatefulWidget {
  final String username;
  final String imageUrl;
  final int likes;
  final int comments;

  const PostWidget({
    required this.username,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    Key? key,
  }) : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isLiked = false;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    likeCount = widget.likes;
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
  }

  void openCommentScreen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CommentScreen(username: widget.username),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF61D384), // Dark background for the post
        borderRadius: BorderRadius.circular(12), // Rounded corners
        border: Border.all(width: 2), // Dark green border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFC3F44D),
              child: Text(widget.username[0],
                  style: const TextStyle(color: Colors.black)),
            ),
            title: Text(widget.username,
                style: const TextStyle(color: Color(0xFF1A434E))),
          ),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(12), // Rounded corners for the image
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 2), // Black border for the image
                borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
              child: Image.asset(
                widget.imageUrl,
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
                // Like Button
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.white,
                  ),
                  onPressed: toggleLike,
                ),
                Text('$likeCount likes',
                    style: const TextStyle(color: Colors.white)),

                const SizedBox(width: 16),

                // Comment Button
                IconButton(
                  icon: Icon(Icons.comment, color: Color(0xFF1A434E)),
                  onPressed: () => openCommentScreen(context), // Now it works!
                ),
                Text('${widget.comments} comments',
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
