import 'package:flutter/material.dart';
import 'booking_page.dart';
import 'selectfield_page.dart'; // Import the SelectFieldPage
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'comment_screen.dart';
import 'login.dart';
import 'signup.dart';
import 'choicecard.dart';
import 'gettingstarted.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 2;

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
      initialRoute:
          '/gettingstarted', // Set the initial route to the login page
      routes: {
        '/': (context) => Scaffold(
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
                          style: TextStyle(
                              color: const Color.fromARGB(255, 0, 0, 0))),
                      onTap: () {},
                    ),
                    ListTile(
                      leading:
                          Icon(Icons.sports_soccer, color: Color(0xFF61D384)),
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
                      leading:
                          Icon(Icons.notifications, color: Color(0xFF61D384)),
                      title: Text('Notifications',
                          style: TextStyle(
                              color: const Color.fromARGB(0, 255, 255, 255))),
                      onTap: () {},
                    ),
                    ListTile(
                      leading:
                          Icon(Icons.privacy_tip, color: Color(0xFF61D384)),
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
                buttonBackgroundColor:
                    Color(0xFF61D384), // Highlighted item color
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
        '/booking_page': (context) => BookingPage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/choicecard': (context) => UserChoicePage(),
        '/gettingstarted': (context) => GettingStartedPage(),
      },
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
    super.key,
  });

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
