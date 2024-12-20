// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class OrderFinalPage extends StatelessWidget {
//   final double totalDistance;

//   const OrderFinalPage({Key? key, required this.totalDistance})
//       : super(key: key);

//   // Function to handle the Confirm button press
//   Future<void> _handleConfirm(BuildContext context) async {
//     final userId = FirebaseAuth.instance.currentUser?.uid;
//     if (userId == null) return; // If the user is not logged in, exit.

//     try {
//       // Get the Firestore instance
//       final firestore = FirebaseFirestore.instance;

//       // Fetch the orders from live_order_details where the userId matches the logged-in user
//       final ordersSnapshot = await firestore
//           .collection('live_order_details')
//           .where('userId', isEqualTo: userId)
//           .get();

//       if (ordersSnapshot.docs.isEmpty) {
//         // If no orders are found for the logged-in user
//         print('No orders found for the user.');
//         return;
//       }

//       // Get the first order (assuming there's only one order for this user)
//       final order = ordersSnapshot.docs.first;

//       // Move the order to finished_order_details
//       await firestore
//           .collection('finished_order_details')
//           .doc(order.id)
//           .set(order.data());

//       // Delete the order from live_order_details
//       await firestore.collection('live_order_details').doc(order.id).delete();

//       // Update the available document for the user ID to "start"
//       await firestore.collection('available').doc(userId).update({
//         'status': 'start',
//       });

//       // Navigate to the admin home screen
//       Navigator.pushReplacementNamed(context,
//           '/home'); // Use pushReplacementNamed to replace the current screen
//     } catch (e) {
//       print('Error during confirm: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Order Final'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Displaying total distance
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       'Total Distance: ${totalDistance.toStringAsFixed(2)} km',
//                       style: const TextStyle(
//                           fontSize: 20, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   const SizedBox(
//                       width:
//                           16), // Ensure there is a comma here if this is part of a list.
//                   ElevatedButton(
//                     onPressed: () => _handleConfirm(context),
//                     child: const Text('Confirm'),
//                   ),
//                 ],
//               ),

//               const SizedBox(
//                   height:
//                       16), // Add a comma if this is part of a larger widget tree

//               // Fetch live order details from Firestore and display them
//               StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('live_order_details')
//                     .orderBy('timestamp', descending: true)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return const Center(child: Text('No orders found.'));
//                   }

//                   final orders = snapshot.data!.docs;

//                   return ListView.builder(
//                     shrinkWrap:
//                         true, // Use shrinkWrap to fit content within column
//                     itemCount: orders.length,
//                     itemBuilder: (context, index) {
//                       final order =
//                           orders[index].data() as Map<String, dynamic>;
//                       final restaurant =
//                           order['restaurant'] as Map<String, dynamic>?;
//                       final parcels = order['parcels'] as List<dynamic>;
//                       final orderUserId =
//                           order['userId']; // Fetch the userId from Firestore

//                       // Compare Firestore userId with the logged-in user's ID
//                       if (orderUserId !=
//                           FirebaseAuth.instance.currentUser?.uid) {
//                         return const SizedBox
//                             .shrink(); // Skip this order if IDs don't match
//                       }

//                       return Card(
//                         margin: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 8),
//                         child: Padding(
//                           padding: const EdgeInsets.all(12),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Order ID: ${orders[index].id}',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               // Display userId only if it matches the logged-in user
//                               Text(
//                                 'User ID: $orderUserId',
//                                 style: const TextStyle(fontSize: 14),
//                               ),
//                               const SizedBox(height: 8),
//                               if (restaurant != null) ...[
//                                 Text(
//                                   'Restaurant: ${restaurant['name']}',
//                                   style: const TextStyle(fontSize: 14),
//                                 ),
//                                 Text(
//                                   'Address: ${restaurant['address']}',
//                                   style: const TextStyle(fontSize: 14),
//                                 ),
//                                 Text(
//                                   'Coordinates: ${restaurant['coordinates']}',
//                                   style: const TextStyle(fontSize: 14),
//                                 ),
//                               ],
//                               const SizedBox(height: 12),
//                               const Text(
//                                 'Parcels:',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               ...parcels.map((parcel) {
//                                 final parcelMap =
//                                     parcel as Map<String, dynamic>;
//                                 return Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text('Name: ${parcelMap['name']}'),
//                                     Text('Address: ${parcelMap['address']}'),
//                                     Text(
//                                         'Postal Code: ${parcelMap['postal_code']}'),
//                                     Text(
//                                         'Mobile Number: ${parcelMap['mobile_number']}'),
//                                     Text(
//                                         'Coordinates: ${parcelMap['coordinates']}'),
//                                     Text('Status: ${parcelMap['status']}'),
//                                     const Divider(),
//                                   ],
//                                 );
//                               }).toList(),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'Timestamp: ${order['timestamp']?.toDate()}',
//                                 style: const TextStyle(fontSize: 14),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
