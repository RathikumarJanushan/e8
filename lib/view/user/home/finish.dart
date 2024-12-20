// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class OrderFinishPage extends StatelessWidget {
//   final String totalDistance;

//   const OrderFinishPage({Key? key, required this.totalDistance})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Get the current user's UID directly
//     final String userId = FirebaseAuth.instance.currentUser!.uid;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Order Details & Finish'),
//         backgroundColor:
//             const Color.fromARGB(255, 63, 63, 63), // Dark app bar color
//       ),
//       backgroundColor:
//           const Color.fromARGB(255, 63, 63, 63), // Dark background color
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
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white, // White text for dark mode
//                 ),
//               ),
//               ..._buildPickups(data['pickupData'] ?? []),
//               SizedBox(height: 20),
//               Text(
//                 "Deliveries",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white, // White text for dark mode
//                 ),
//               ),
//               ..._buildDeliveries(data['deliveryData'] ?? []),
//               SizedBox(height: 20),
//               Text(
//                 "Order Status: ${data['status'] ?? 'N/A'}",
//                 style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.white), // White text for dark mode
//               ),
//               Text(
//                 "Timestamp: ${data['timestamp']?.toDate().toString() ?? 'N/A'}",
//                 style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.white), // White text for dark mode
//               ),
//               SizedBox(height: 20),
//               // Display Total Distance with dark background styling
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors
//                       .grey[800], // Slightly lighter grey for the container
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.2),
//                       blurRadius: 6,
//                     ),
//                   ],
//                 ),
//                 child: Text(
//                   'Total Distance: $totalDistance',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white, // White text for dark mode
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               SizedBox(height: 20),
//               // Confirmation Button
//               ElevatedButton(
//                 onPressed: () async {
//                   // Get a reference to Firestore
//                   final orderDetailsRef = FirebaseFirestore.instance
//                       .collection('order_details')
//                       .doc(userId);
//                   final orderHistoryRef =
//                       FirebaseFirestore.instance.collection('order_history');

//                   try {
//                     // Fetch the data of the current order
//                     final snapshot = await orderDetailsRef.get();
//                     if (!snapshot.exists) {
//                       throw 'Order details not found';
//                     }

//                     // Prepare the data to be saved to the order_history collection
//                     final orderData = snapshot.data() as Map<String, dynamic>;

//                     // Include the totalDistance in the order data
//                     orderData['totalDistance'] = totalDistance;

//                     // Add the data to the order_history collection with auto-generated ID
//                     await orderHistoryRef.add(orderData);

//                     // Delete the document from order_details
//                     await orderDetailsRef.delete();

//                     // Show success message
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                           content:
//                               Text('Order confirmed and moved to history.')),
//                     );

//                     // Optionally, navigate back or to another page
//                     Navigator.pop(context);
//                   } catch (e) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Error: $e')),
//                     );
//                   }
//                 },
//                 child: Text('Confirm Order'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green, // Button color
//                   padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//                   textStyle: TextStyle(fontSize: 16),
//                 ),
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
//         color: Colors.grey[850], // Dark card color for deliveries
//         child: Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Address: ${delivery['address'] ?? 'N/A'}",
//                   style: TextStyle(fontSize: 16, color: Colors.white)),
//               ...deliveryDetails.map((details) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 5),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Name: ${details['name'] ?? 'N/A'}",
//                           style: TextStyle(color: Colors.white)),
//                       Text("Phone: ${details['phone'] ?? 'N/A'}",
//                           style: TextStyle(color: Colors.white)),
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
//         color: Colors.grey[850], // Dark card color for pickups
//         child: Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Address: ${pickup['address'] ?? 'N/A'}",
//                   style: TextStyle(fontSize: 16, color: Colors.white)),
//               Text("Parcels: ${parcels.join(', ')}",
//                   style: TextStyle(color: Colors.white)),
//             ],
//           ),
//         ),
//       );
//     }).toList();
//   }
// }
