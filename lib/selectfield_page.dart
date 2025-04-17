import 'package:flutter/material.dart';
//import 'package:lucide_icons/lucide_icons.dart';

class SelectFieldPage extends StatelessWidget {
  const SelectFieldPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A434E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Find your futsal field",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    Icons.notifications,
                    color: Colors.white,
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ChoiceChip(
                    label: Text("Indoor"),
                    selected: true,
                    selectedColor: Color(0xFF61D384),
                    labelStyle: TextStyle(color: Colors.white),
                    onSelected: (value) {},
                  ),
                  SizedBox(width: 10),
                  ChoiceChip(
                    label: Text("Outdoor"),
                    selected: false,
                    selectedColor: Color(0xFF61D384),
                    labelStyle: TextStyle(color: Colors.white),
                    onSelected: (value) {},
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Container(
                      width: MediaQuery.of(context).size.width *
                          0.8, // Set width to 80% of screen width
                      margin: EdgeInsets.only(right: 16.0),
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 500,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                              image: DecorationImage(
                                image:
                                    AssetImage("assets/field${index + 1}.jpg"),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  // ignore: deprecated_member_use
                                  Colors.black.withOpacity(0.3),
                                  BlendMode.darken,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Color(0xFF61D384),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "\$${50 + index * 10}/Hour",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Futsal Arena ${index + 1}",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "City Center",
                                      style: TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            right: 16,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/booking_page');
                              },
                              child: CircleAvatar(
                                backgroundColor: Color(0xFFC3F44D),
                                radius: 20,
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFF1A434E),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
