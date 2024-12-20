import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DetailsScreen extends StatefulWidget {
  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String userId;
  late String email;
  String name = 'Loading...';
  String available = 'No available'; // Default available status

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  // Fetch user details and available status from Firestore
  Future<void> _getUserDetails() async {
    User? user = _auth.currentUser;

    if (user != null) {
      userId = user.uid;
      email = user.email ?? 'No email found';

      try {
        // Fetch user details from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('usersdetails')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          setState(() {
            name = userDoc['name'] ?? 'No name found';
          });
        } else {
          setState(() {
            name = 'No details found for this user';
          });
        }

        // Fetch available status
        DocumentSnapshot availableDoc = await FirebaseFirestore.instance
            .collection('available')
            .doc(userId)
            .get();

        if (availableDoc.exists) {
          setState(() {
            available = availableDoc['available'] ?? 'No available';
          });
        }
      } catch (e) {
        setState(() {
          available = 'Error fetching available';
        });
      }
    }
  }

  // Save data to Firestore when button is pressed
  Future<void> _saveData(String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('available')
          .doc(userId)
          .set({'email': email, 'available': status});

      setState(() {
        available = status; // Update available status locally
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $status')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  // Get box color based on available status
  Color _getBoxColor() {
    switch (available) {
      case 'start':
        return Colors.green;
      case 'end':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
        automaticallyImplyLeading: false, // Removes the back button
      ),
      body: Center(
        child: userId.isEmpty
            ? CircularProgressIndicator() // Show loading while fetching data
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Box to display user details
                  Container(
                    padding: EdgeInsets.all(16.0),
                    margin: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: _getBoxColor(), // Dynamic box color
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('User ID: $userId'),
                        Text('Email: $email'),
                        Text('Name: $name'),
                        Text('available: $available'),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Buttons to set status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => _saveData('start'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20), // Rounded corners
                          ),
                          backgroundColor:
                              Colors.green, // Button background color
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.play_arrow,
                                color: Colors.white), // Icon for Start
                            SizedBox(width: 8),
                            Text('Start', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () => _saveData('end'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20), // Rounded corners
                          ),
                          backgroundColor:
                              Colors.red, // Button background color
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.stop,
                                color: Colors.white), // Icon for End
                            SizedBox(width: 8),
                            Text('End', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
      ),
    );
  }
}
