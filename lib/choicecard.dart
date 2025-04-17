import 'package:flutter/material.dart';
import 'package:futolo/signup.dart';

class UserChoicePage extends StatefulWidget {
  const UserChoicePage({super.key});

  @override
  _UserChoicePageState createState() => _UserChoicePageState();
}

class _UserChoicePageState extends State<UserChoicePage> {
  String selectedUserType = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A434E), // Dark Background
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Sign Up",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Choose your account type",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildChoiceCard("Organizer", Icons.business_center),
                SizedBox(width: 20),
                _buildChoiceCard("User", Icons.person),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: selectedUserType.isNotEmpty
                  ? () {
                      // Navigate based on selection
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupPage()),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC3F44D),
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text("Select", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceCard(String type, IconData icon) {
    bool isSelected = selectedUserType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedUserType = type;
        });
      },
      child: Container(
        width: 120,
        height: 150,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFC3F44D) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.black54),
            SizedBox(height: 10),
            Text(
              type,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
