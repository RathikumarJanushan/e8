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
  String name =
      'Loading...'; // Set default value to avoid late initialization error

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  // Fetch user details from Firestore
  Future<void> _getUserDetails() async {
    User? user = _auth.currentUser;

    if (user != null) {
      userId = user.uid;
      email = user.email ?? 'No email found';

      // Fetch user details from Firestore
      try {
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
      } catch (e) {
        setState(() {
          name = 'Error fetching user details';
        });
      }
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User ID: $userId'),
                  Text('Email: $email'),
                  Text('Name: $name'),
                ],
              ),
      ),
    );
  }
}
