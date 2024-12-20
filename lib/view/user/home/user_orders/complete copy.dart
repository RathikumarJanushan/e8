// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class CompletePage extends StatefulWidget {
//   const CompletePage({Key? key}) : super(key: key);

//   @override
//   State<CompletePage> createState() => _CompletePageState();
// }

// class _CompletePageState extends State<CompletePage> {
//   final Set<Polyline> _polylines = {};
//   double _totalDistance = 0.0;
//   Set<Marker> _previousMarkers = {};
//   Map<String, dynamic>? _selectedOrder;

//   Future<void> _fetchDirectionsAndDistance(Set<Marker> markers) async {
//     if (markers.length < 2) return;

//     // Helper function to compare sets
//     bool areSetsEqual(Set<Marker> set1, Set<Marker> set2) {
//       if (set1.length != set2.length) return false;
//       for (final element in set1) {
//         if (!set2.contains(element)) return false;
//       }
//       return true;
//     }

//     if (areSetsEqual(_previousMarkers, markers)) {
//       return; // No need to re-fetch if markers are the same
//     }
//     _previousMarkers = markers;

//     final apiKey = 'AIzaSyCZlAYZGHG2-FgU8CKOWjL-JqPpOVQdiXY';
//     final List<LatLng> markerPositions =
//         markers.map((marker) => marker.position).toList();

//     final origin = markerPositions.first;
//     final destination = markerPositions.last;
//     final waypoints = markerPositions
//         .skip(1)
//         .take(markerPositions.length - 2)
//         .map((latLng) => '${latLng.latitude},${latLng.longitude}')
//         .join('|');

//     final url =
//         'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&waypoints=$waypoints&key=$apiKey';

//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final routes = data['routes'] as List<dynamic>;
//       if (routes.isNotEmpty) {
//         final polylinePoints = routes[0]['overview_polyline']['points'];
//         final decodedPoints = _decodePolyline(polylinePoints);
//         final legs = routes[0]['legs'] as List<dynamic>;

//         // Calculate total distance
//         double distance = 0.0;
//         for (var leg in legs) {
//           distance += leg['distance']['value']; // in meters
//         }
//         setState(() {
//           _totalDistance = distance / 1000; // Convert to kilometers
//           _polylines.clear();
//           _polylines.add(Polyline(
//             polylineId: const PolylineId('route'),
//             points: decodedPoints,
//             color: Colors.blue,
//             width: 5,
//           ));
//         });
//       }
//     }
//   }

//   List<LatLng> _decodePolyline(String encoded) {
//     List<LatLng> points = [];
//     int index = 0, len = encoded.length;
//     int lat = 0, lng = 0;

//     while (index < len) {
//       int b, shift = 0, result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
//       lat += dLat;

//       shift = 0;
//       result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
//       lng += dLng;

//       points.add(LatLng(lat / 1E5, lng / 1E5));
//     }
//     return points;
//   }

//   Future<void> _saveToFinishedOrders() async {
//     if (_selectedOrder == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('No order selected to confirm.')),
//       );
//       return;
//     }

//     try {
//       // Add order to finished orders
//       await FirebaseFirestore.instance
//           .collection('finished_order_details')
//           .add({
//         'restaurant': _selectedOrder!['restaurant'],
//         'userId': _selectedOrder!['userId'],
//         'parcels': _selectedOrder!['parcels'],
//         'totalDistance': _totalDistance,
//         'timestamp': FieldValue.serverTimestamp(),
//       });

//       // Get the orderId from the selected order
//       final orderId = _selectedOrder!['orderId'];

//       // If orderId is available, delete the order from live orders
//       if (orderId != null) {
//         await FirebaseFirestore.instance
//             .collection('live_order_details')
//             .doc(orderId) // Using the correct orderId
//             .delete();

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text(
//                   'Order saved to finished orders and deleted from live orders.')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Order ID not found.')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error saving or deleting order: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentUserId = FirebaseAuth.instance.currentUser?.uid;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Live Orders'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('live_order_details')
//             .orderBy('timestamp', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No orders found.'));
//           }

//           final orders = snapshot.data!.docs;
//           final Set<Marker> markers = {};

//           final orderWidgets = orders.map((doc) {
//             final order = doc.data() as Map<String, dynamic>;
//             final userId = order['userId'];

//             if (userId != currentUserId) {
//               return const SizedBox.shrink();
//             }

//             _selectedOrder ??= order; // Set the first order as selected

//             final restaurant = order['restaurant'] as Map<String, dynamic>?;
//             final parcels = order['parcels'] as List<dynamic>;

//             // Add restaurant marker
//             if (restaurant != null && restaurant['coordinates'] != null) {
//               final coordinates = restaurant['coordinates'];
//               markers.add(Marker(
//                 markerId: MarkerId('restaurant-${doc.id}'),
//                 position:
//                     LatLng(coordinates['latitude'], coordinates['longitude']),
//                 infoWindow: InfoWindow(title: restaurant['name']),
//               ));
//             }

//             // Add parcel markers
//             for (var parcel in parcels) {
//               final parcelMap = parcel as Map<String, dynamic>;
//               final parcelCoordinates =
//                   parcelMap['coordinates'] as Map<String, dynamic>?;
//               if (parcelCoordinates != null) {
//                 markers.add(Marker(
//                   markerId: MarkerId('parcel-${doc.id}-${parcelMap['name']}'),
//                   position: LatLng(parcelCoordinates['latitude'],
//                       parcelCoordinates['longitude']),
//                   infoWindow: InfoWindow(title: parcelMap['name']),
//                 ));
//               }
//             }

//             final data = doc.data() as Map<String, dynamic>?;

//             return Card(
//               margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               child: Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Check if the 'orderId' exists and display it, otherwise use doc.id
//                     Text(
//                       'Order ID: ${data != null && data.containsKey('orderId') ? data['orderId'] : doc.id}',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),




                    
//                     const SizedBox(height: 8),
//                     if (restaurant != null) ...[
//                       Text(
//                         'Restaurant: ${restaurant['name']}',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       const SizedBox(height: 8),
//                       if (restaurant['coordinates'] != null)
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Latitude: ${restaurant['coordinates']['latitude']}',
//                               style: const TextStyle(fontSize: 14),
//                             ),
//                             Text(
//                               'Longitude: ${restaurant['coordinates']['longitude']}',
//                               style: const TextStyle(fontSize: 14),
//                             ),
//                           ],
//                         ),
//                     ],
//                     const SizedBox(height: 12),
//                     const Text(
//                       'Parcels:',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     ...parcels.map((parcel) {
//                       final parcelMap = parcel as Map<String, dynamic>;
//                       final parcelCoordinates =
//                           parcelMap['coordinates'] as Map<String, dynamic>?;

//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Name: ${parcelMap['name']}'),
//                           if (parcelCoordinates != null) ...[
//                             Text('Latitude: ${parcelCoordinates['latitude']}'),
//                             Text(
//                                 'Longitude: ${parcelCoordinates['longitude']}'),
//                           ],
//                           const Divider(),
//                         ],
//                       );
//                     }).toList(),
//                   ],
//                 ),
//               ),
//             );
//           }).toList();

//           // Fetch directions and update polyline
//           _fetchDirectionsAndDistance(markers);

//           return Column(
//             children: [
//               Expanded(
//                 flex: 2,
//                 child: ListView(children: orderWidgets),
//               ),
//               Expanded(
//                 flex: 3,
//                 child: GoogleMap(
//                   initialCameraPosition: const CameraPosition(
//                     target: LatLng(0, 0), // Default location
//                     zoom: 2,
//                   ),
//                   markers: markers,
//                   polylines: _polylines,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Total Distance: ${_totalDistance.toStringAsFixed(2)} km',
//                       style: const TextStyle(
//                           fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 12),
//                     TextButton(
//                       onPressed: _saveToFinishedOrders,
//                       child: const Text(
//                         'Confirm',
//                         style: TextStyle(fontSize: 16),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
