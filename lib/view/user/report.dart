// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:e8/common/color_extension.dart';

// class FinishedOrdersPage extends StatelessWidget {
//   const FinishedOrdersPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     User? user = FirebaseAuth.instance.currentUser;

//     // If user is not logged in, handle this case
//     if (user == null) {
//       return Scaffold(
//         backgroundColor: TColor.background, // Set background color
//         body: Center(
//           child: Text(
//             'User not logged in',
//             style: TextStyle(
//                 fontSize: 18, color: TColor.primaryText), // Set text color
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: TColor.background, // Set background color
//       appBar: AppBar(
//         automaticallyImplyLeading: false, // Remove back button
//         backgroundColor: TColor.primary, // AppBar color
//         title: Text(
//           'Finished Orders',
//           style: TextStyle(color: TColor.primaryText), // Title text color
//         ),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('finished_order_details')
//             .where('userId',
//                 isEqualTo: user.uid) // Filter by the logged-in user's UID
//             .orderBy('timestamp', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           // Display loading indicator while waiting for data
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           // Handle case where there are no finished orders
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(
//               child: Text(
//                 'No finished orders.',
//                 style: TextStyle(
//                     fontSize: 18, color: TColor.primaryText), // Text color
//               ),
//             );
//           }

//           final orders = snapshot.data!.docs;

//           // Build a table of orders
//           return SingleChildScrollView(
//             scrollDirection: Axis.horizontal, // Enable horizontal scrolling
//             child: DataTable(
//               columns: [
//                 DataColumn(
//                   label: Text(
//                     'User ID',
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: TColor.primaryText), // Text color
//                   ),
//                 ),
//                 DataColumn(
//                   label: Text(
//                     'Total Distance (km)',
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: TColor.primaryText), // Text color
//                   ),
//                 ),
//                 DataColumn(
//                   label: Text(
//                     'Timestamp',
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: TColor.primaryText), // Text color
//                   ),
//                 ),
//               ],
//               rows: orders.map((order) {
//                 final orderData = order.data() as Map<String, dynamic>;
//                 final userId = orderData['userId'] ?? 'Unknown'; // Fetch userId
//                 final totalDistance =
//                     orderData['totalDistance']?.toDouble() ?? 0.0;
//                 final timestamp = orderData['timestamp']?.toDate();

//                 return DataRow(
//                   cells: [
//                     DataCell(Text(userId,
//                         style: TextStyle(
//                             color: TColor.primaryText))), // Text color
//                     DataCell(Text(totalDistance.toStringAsFixed(2),
//                         style: TextStyle(
//                             color: TColor.primaryText))), // Text color
//                     DataCell(Text(
//                       timestamp != null ? timestamp.toString() : 'N/A',
//                       style: TextStyle(color: TColor.primaryText), // Text color
//                     )),
//                   ],
//                 );
//               }).toList(),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
