import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FinishedOrdersPage extends StatefulWidget {
  const FinishedOrdersPage({Key? key}) : super(key: key);

  @override
  _FinishedOrdersPageState createState() => _FinishedOrdersPageState();
}

class _FinishedOrdersPageState extends State<FinishedOrdersPage> {
  DateTime _selectedDate = DateTime.now(); // Default to today

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finished Orders'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Calendar to pick a date
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null && pickedDate != _selectedDate) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.blue),
                    const SizedBox(width: 8.0),
                    Text(
                      DateFormat.yMMMMd().format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          // Orders Table
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('finished_order_details')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No finished orders found.',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                final orders = snapshot.data!.docs.where((doc) {
                  final orderData = doc.data() as Map<String, dynamic>;
                  final timestamp =
                      (orderData['timestamp'] as Timestamp?)?.toDate();
                  final sameDay = timestamp != null &&
                      timestamp.year == _selectedDate.year &&
                      timestamp.month == _selectedDate.month &&
                      timestamp.day == _selectedDate.day;
                  return orderData['userId'] == currentUserId && sameDay;
                }).toList();

                if (orders.isEmpty) {
                  return const Center(
                    child: Text(
                      'No finished orders for the selected date.',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                // Calculate total path distance
                final totalPathDistance = orders.fold<double>(
                  0.0,
                  (sum, order) {
                    final orderData = order.data() as Map<String, dynamic>;
                    return sum + (orderData['totalPathDistance'] ?? 0.0);
                  },
                );

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('NO')),
                            DataColumn(label: Text('Time')),
                            DataColumn(label: Text('Restaurant Name')),
                            DataColumn(label: Text('Parcel Names')),
                            DataColumn(label: Text('Total Path Distance')),
                          ],
                          rows: List<DataRow>.generate(
                            orders.length,
                            (index) {
                              final order = orders[index];
                              final orderData =
                                  order.data() as Map<String, dynamic>;
                              final timestamp =
                                  (orderData['timestamp'] as Timestamp?)
                                      ?.toDate();
                              final restaurantName =
                                  orderData['restaurantDetails']?['name'] ??
                                      'Unknown';
                              final parcels = List<Map<String, dynamic>>.from(
                                  orderData['parcelDetails'] ?? []);
                              final totalPathDistance =
                                  orderData['totalPathDistance'] ?? 0.0;
                              final parcelNames = parcels
                                  .map((parcel) => parcel['name'] ?? 'Unknown')
                                  .join(', ');

                              return DataRow(
                                cells: [
                                  DataCell(Text((index + 1).toString())),
                                  DataCell(Text(
                                    timestamp != null
                                        ? DateFormat.jm().format(timestamp)
                                        : 'Unknown',
                                  )),
                                  DataCell(Text(restaurantName)),
                                  DataCell(Text(parcelNames)),
                                  DataCell(Text(
                                      '${totalPathDistance.toStringAsFixed(2)} km')),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    // Display the total path distance
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Total Path Distance: ${totalPathDistance.toStringAsFixed(2)} km',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
