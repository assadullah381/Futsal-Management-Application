import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

class BookingPage extends StatefulWidget {
  final String fieldName;
  const BookingPage({super.key, required this.fieldName});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final Client client = Client()
    ..setEndpoint('https://fra.cloud.appwrite.io/v1')
    ..setProject('67d0e2dd00399b43677c');

  late final Databases databases;

  late final Account account;
  String? userId;

  @override
  void initState() {
    super.initState();
    databases = Databases(client);
    account = Account(client);
    getCurrentUser();
  }

  Future<void> getCurrentUser() async {
    try {
      final models.User user = await account.get();
      setState(() {
        userId = user.$id;
      });
    } catch (e) {
      print('User not logged in: $e');
    }
  }

  int selectedDateIndex = 0;
  int selectedTimeIndex = 0;

  final List<String> dates = ["13 Mon", "14 Tue", "17 Fri", "19 Sun"];
  final List<String> times = ["12:30 - 13:30", "13:45 - 14:45"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A434E), // Dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderImage(),
            SizedBox(height: 20),
            _buildDateSelector(),
            SizedBox(height: 20),
            _buildTimeSelector(),
            SizedBox(height: 20),
            _buildPriceAndButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(
              "assets/futsal-court-construction.jpg"), // Change this to your image asset
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 15,
            left: 15,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Color(0xFF61D384),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Chestnut Av. B2",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select a reservation date",
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dates.length, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedDateIndex = index;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(
                  color: selectedDateIndex == index
                      ? Color(0xFFC3F44D)
                      : Colors.transparent,
                  border: Border.all(color: Color(0xFFC3F44D)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  dates[index],
                  style: GoogleFonts.poppins(
                    color: selectedDateIndex == index
                        ? Colors.black
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select a time slot",
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(times.length, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedTimeIndex = index;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(
                  color: selectedTimeIndex == index
                      ? Color(0xFFC3F44D)
                      : Colors.transparent,
                  border: Border.all(color: Color(0xFFC3F44D)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  times[index],
                  style: GoogleFonts.poppins(
                    color: selectedTimeIndex == index
                        ? Colors.black
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPriceAndButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Price",
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
        ),
        Text(
          "\$44.50",
          style: GoogleFonts.poppins(
            color: Color(0xFFC3F44D),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: userId == null
              ? null
              : () async {
                  try {
                    await databases.createDocument(
                      databaseId: 'your_database_id',
                      collectionId: 'bookings',
                      documentId: ID.unique(),
                      data: {
                        'userId': userId,
                        'fieldName': widget.fieldName,
                        'date': dates[selectedDateIndex],
                        'timeSlot': times[selectedTimeIndex],
                        'price': 44.50,
                        'status': 'pending',
                      },
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Booking successful!')),
                    );

                    Navigator.pop(context);
                  } catch (e) {
                    print('Booking failed: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Booking failed. Try again.')),
                    );
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF61D384),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.symmetric(vertical: 15),
          ),
          child: Center(
            child: Text(
              "Book Now",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
