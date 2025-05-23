import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'appwrite_service.dart'; // Import your Appwrite setup

import 'booking_page.dart'; // Import your BookingPage

class SelectFieldPage extends StatefulWidget {
  const SelectFieldPage({super.key});

  @override
  State<SelectFieldPage> createState() => _SelectFieldPageState();
}

class _SelectFieldPageState extends State<SelectFieldPage> {
  final Databases databases =
      Databases(AppwriteService.client); // Initialize with your Appwrite client
  List<models.Document> fields = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize databases in the declaration itself, no reassignment needed here.
    fetchFields();
  }

  Future<void> fetchFields() async {
    try {
      final result = await databases.listDocuments(
        databaseId: 'YOUR_DATABASE_ID',
        collectionId: 'fields',
      );
      setState(() {
        fields = result.documents;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching fields: $e');
      setState(() => isLoading = false);
    }
  }

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
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: fields.length,
                        itemBuilder: (context, index) {
                          final field = fields[index];
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.8,
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
                                      image: NetworkImage(
                                          field.data['imageUrl'] ?? ''),
                                      fit: BoxFit.cover,
                                      colorFilter: ColorFilter.mode(
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
                                      "\$${field.data['pricePerHour']}/Hour",
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        field.data['name'] ?? 'Futsal Arena',
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
                                            field.data['location'] ?? 'Unknown',
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
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BookingPage(
                                              fieldName: field.data['name']),
                                        ),
                                      );
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
