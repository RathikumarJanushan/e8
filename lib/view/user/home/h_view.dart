import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderHistoryViewPage extends StatelessWidget {
  // Get the current user's UID
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
        backgroundColor:
            const Color.fromARGB(255, 25, 25, 25), // Dark app bar color
      ),
      backgroundColor:
          const Color.fromARGB(255, 40, 40, 40), // Dark background color
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('order_history')
            .where('userId',
                isEqualTo: userId) // Query by userId (current logged-in user)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No order history found.'));
          }

          final orderHistoryDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: orderHistoryDocs.length,
            itemBuilder: (context, index) {
              final orderData =
                  orderHistoryDocs[index].data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.only(top: 10),
                color: const Color.fromARGB(
                    255, 247, 247, 247), // Dark card color for history
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Distance: ${orderData['totalDistance'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      Text(
                        'Timestamp: ${orderData['timestamp']?.toDate().toString() ?? 'N/A'}',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
