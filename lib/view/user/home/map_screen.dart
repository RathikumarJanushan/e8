// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class OrderDetailsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // Get the current user's UID directly
//     final String userId = FirebaseAuth.instance.currentUser!.uid;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Order Details'),
//       ),
//       body: FutureBuilder<DocumentSnapshot>(
//         future: FirebaseFirestore.instance
//             .collection('order_details')
//             .doc(userId)
//             .get(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data == null) {
//             return Center(child: Text('No data found.'));
//           }

//           final data = snapshot.data!.data() as Map<String, dynamic>;

//           return ListView(
//             padding: EdgeInsets.all(16),
//             children: [
//               Text(
//                 "Pickups",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               ..._buildPickups(data['pickupData'] ?? []),
//               SizedBox(height: 20),
//               Text(
//                 "Deliveries",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               ..._buildDeliveries(data['deliveryData'] ?? []),
//               SizedBox(height: 20),
//               Text(
//                 "Order Status: ${data['status'] ?? 'N/A'}",
//                 style: TextStyle(fontSize: 16),
//               ),
//               Text(
//                 "Timestamp: ${data['timestamp']?.toDate().toString() ?? 'N/A'}",
//                 style: TextStyle(fontSize: 16),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   List<Widget> _buildDeliveries(List<dynamic> deliveries) {
//     return deliveries.map<Widget>((delivery) {
//       final deliveryDetails =
//           delivery['deliveryDetails'] as List<dynamic>? ?? [];
//       return Card(
//         margin: EdgeInsets.only(top: 10),
//         child: Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Address: ${delivery['address'] ?? 'N/A'}",
//                   style: TextStyle(fontSize: 16)),
//               ...deliveryDetails.map((details) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 5),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Name: ${details['name'] ?? 'N/A'}"),
//                       Text("Phone: ${details['phone'] ?? 'N/A'}"),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ],
//           ),
//         ),
//       );
//     }).toList();
//   }

//   List<Widget> _buildPickups(List<dynamic> pickups) {
//     return pickups.map<Widget>((pickup) {
//       final parcels = pickup['parcels'] as List<dynamic>? ?? [];
//       return Card(
//         margin: EdgeInsets.only(top: 10),
//         child: Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Address: ${pickup['address'] ?? 'N/A'}",
//                   style: TextStyle(fontSize: 16)),
//               Text("Parcels: ${parcels.join(', ')}"),
//             ],
//           ),
//         ),
//       );
//     }).toList();
//   }
// }

// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Home'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             // Navigate to the OrderDetailsPage directly
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => OrderDetailsPage(),
//               ),
//             );
//           },
//           child: Text('View Order Details'),
//         ),
//       ),
//     );
//   }
// }
