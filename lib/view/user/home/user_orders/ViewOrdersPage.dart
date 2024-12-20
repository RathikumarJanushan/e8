import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ViewOrdersPage extends StatelessWidget {
  const ViewOrdersPage({Key? key}) : super(key: key);

  Future<double> fetchDrivingDistance(
      double startLat, double startLon, double endLat, double endLon) async {
    const String apiKey =
        'AIzaSyCZlAYZGHG2-FgU8CKOWjL-JqPpOVQdiXY'; // Replace with your API key
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$startLat,$startLon&destination=$endLat,$endLon&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final distanceMeters = data['routes'][0]['legs'][0]['distance']['value']
          as int; // Distance in meters
      return distanceMeters / 1000; // Convert to kilometers
    } else {
      throw Exception('Failed to fetch driving distance');
    }
  }

  Future<List<Map<String, dynamic>>> calculatePathDistances(
      Map<String, dynamic> restaurant,
      List<Map<String, dynamic>> parcels) async {
    final restaurantLat = restaurant['latitude'];
    final restaurantLon = restaurant['longitude'];

    for (var parcel in parcels) {
      final distance = await fetchDrivingDistance(
        restaurantLat,
        restaurantLon,
        parcel['latitude'],
        parcel['longitude'],
      );
      parcel['distanceFromRestaurant'] = distance;
    }

    parcels.sort((a, b) =>
        a['distanceFromRestaurant'].compareTo(b['distanceFromRestaurant']));

    for (int i = 0; i < parcels.length; i++) {
      if (i == 0) {
        parcels[i]['pathDistance'] = parcels[i]['distanceFromRestaurant'];
      } else {
        final pathDistance = await fetchDrivingDistance(
          parcels[i - 1]['latitude'],
          parcels[i - 1]['longitude'],
          parcels[i]['latitude'],
          parcels[i]['longitude'],
        );
        parcels[i]['pathDistance'] = pathDistance;
      }
    }

    return parcels;
  }

  Future<void> markOrderAsFinished(BuildContext context,
      Map<String, dynamic> orderData, String orderId) async {
    try {
      // Calculate the Total Path Distance
      final parcels =
          List<Map<String, dynamic>>.from(orderData['parcelDetails'] ?? []);
      final totalPathDistance = parcels.fold(
          0.0, (sum, parcel) => sum + (parcel['pathDistance'] ?? 0.0));

      // Add Total Path Distance to orderData
      orderData['totalPathDistance'] = totalPathDistance;

      // Save the order in finished_order_details
      await FirebaseFirestore.instance
          .collection('finished_order_details')
          .doc(orderId)
          .set(orderData);

      // Remove the order from live_order_details
      await FirebaseFirestore.instance
          .collection('live_order_details')
          .doc(orderId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order moved to Finished Orders')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to finish order: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Orders'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('live_order_details')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No orders found.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderData = order.data() as Map<String, dynamic>;
              final userId = orderData['userId'] ?? 'Unknown User';

              if (userId != currentUserId) {
                return const SizedBox.shrink();
              }

              final restaurant =
                  orderData['restaurantDetails'] as Map<String, dynamic>?;
              final parcels = List<Map<String, dynamic>>.from(
                  orderData['parcelDetails'] ?? []);
              final timestamp =
                  (orderData['timestamp'] as Timestamp?)?.toDate();

              return FutureBuilder<List<Map<String, dynamic>>>(
                future: restaurant != null
                    ? calculatePathDistances(restaurant, parcels)
                    : Future.value(parcels),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  final sortedParcels = snapshot.data ?? [];

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('User ID: $userId',
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                          if (timestamp != null)
                            Text('Time: ${timestamp.toLocal()}'),
                          if (restaurant != null) ...[
                            const Divider(),
                            const Text(
                              'Restaurant Details:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final latitude = restaurant['latitude'];
                                final longitude = restaurant['longitude'];
                                final googleMapsUrl =
                                    'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving';
                                if (await canLaunch(googleMapsUrl)) {
                                  await launch(googleMapsUrl);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Could not open Google Maps')),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Name: ${restaurant['name']}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text('Address: ${restaurant['address']}'),
                                    Text(
                                        'Coordinates: Lat ${restaurant['latitude']}, Long ${restaurant['longitude']}'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          if (sortedParcels.isNotEmpty) ...[
                            const Divider(),
                            const Text(
                              'Parcels:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...sortedParcels.asMap().entries.map((entry) {
                              final index = entry.key;
                              final parcel = entry.value;
                              return GestureDetector(
                                onTap: () async {
                                  final latitude = parcel['latitude'];
                                  final longitude = parcel['longitude'];
                                  final googleMapsUrl =
                                      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving';
                                  if (await canLaunch(googleMapsUrl)) {
                                    await launch(googleMapsUrl);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Could not open Google Maps')),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sequence: ${index + 1}',
                                        style: const TextStyle(
                                            fontSize:
                                                14.0), // Smaller font size
                                      ),
                                      Text(
                                        'Name: ${parcel['name']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0, // Larger font size
                                        ),
                                      ),
                                      Text(
                                        'Address: ${parcel['address']}',
                                        style: const TextStyle(
                                          fontSize: 16.0, // Larger font size
                                        ),
                                      ),
                                      Text(
                                        'Payment: ${parcel['payment_method']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0, // Larger font size
                                        ),
                                      ),
                                      Text(
                                        'Cash Amount: ${parcel['cash_amount']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0, // Larger font size
                                        ),
                                      ),
                                      Text(
                                        'Status: ${parcel['status']}',
                                        style: const TextStyle(
                                            fontSize:
                                                14.0), // Smaller font size
                                      ),
                                      Text(
                                        'Coordinates: Lat ${parcel['latitude']}, Long ${parcel['longitude']}',
                                        style: const TextStyle(
                                            fontSize:
                                                14.0), // Smaller font size
                                      ),
                                      Text(
                                        'Distance from Restaurant: ${parcel['distanceFromRestaurant']?.toStringAsFixed(2)} km',
                                        style: const TextStyle(
                                            fontSize:
                                                14.0), // Smaller font size
                                      ),
                                      Text(
                                        'Path Distance: ${parcel['pathDistance']?.toStringAsFixed(2)} km',
                                        style: const TextStyle(
                                            fontSize:
                                                14.0), // Smaller font size
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                            const Divider(),
                            Text(
                              'Total Path Distance: ${sortedParcels.fold(0.0, (sum, parcel) => sum + (parcel['pathDistance'] ?? 0.0)).toStringAsFixed(2)} km',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              markOrderAsFinished(context, orderData, order.id);
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize:
                                  const Size(200, 60), // Large button size
                              backgroundColor: Colors
                                  .transparent, // Make the background transparent to apply gradient
                              shadowColor:
                                  Colors.grey.withOpacity(0.5), // Soft shadow
                              elevation: 10, // Shadow elevation
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    30), // Rounded corners
                              ),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF42A5F5),
                                    Color(0xFF1E88E5)
                                  ], // Gradient colors
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(
                                    30), // Match button shape
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                height: 60,
                                child: const Text(
                                  'Finish Order',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white, // Text color
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
