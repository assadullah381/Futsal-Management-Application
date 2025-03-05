import 'package:flutter/material.dart';

class ChoiceCard extends StatelessWidget {
  final String title;
  final bool isSelected;

  ChoiceCard({required this.title, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFFC3F44D) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            title == 'Organizer' ? Icons.business : Icons.person,
            size: 50,
            color: Color(0xFF1A434E),
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A434E),
            ),
          ),
        ],
      ),
    );
  }
}
