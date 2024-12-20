// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geocoding/geocoding.dart' as geocoding;
// import 'package:location/location.dart' as location;
// import 'package:http/http.dart' as http;
// import 'package:e8/common/color_extension.dart';
// import 'package:e8/view/user/home/finish.dart';

// class PathPage extends StatefulWidget {
//   final List<String> pickups;
//   final List<String> deliveries;

//   const PathPage({
//     Key? key,
//     required this.pickups,
//     required this.deliveries,
//   }) : super(key: key);

//   @override
//   State<PathPage> createState() => _PathPageState();
// }

// class _PathPageState extends State<PathPage> {
//   late GoogleMapController mapController;
//   final Set<Marker> _markers = {};
//   final Set<Polyline> _polylines = {};
//   LatLng? _currentLocation;
//   final location.Location _location = location.Location();
//   final LatLng _defaultLocation =
//       LatLng(9.322001, 80.728856); // Default location
//   bool _isLoading = true;
//   String _totalDistance = "Calculating...";

//   @override
//   void initState() {
//     super.initState();
//     _initializeLocation();
//     _addMarkersAndFetchDirections();
//   }

//   Future<void> _initializeLocation() async {
//     try {
//       bool _serviceEnabled;
//       location.PermissionStatus _permissionGranted;

//       _serviceEnabled = await _location.serviceEnabled();
//       if (!_serviceEnabled) {
//         _serviceEnabled = await _location.requestService();
//         if (!_serviceEnabled) return;
//       }

//       _permissionGranted = await _location.hasPermission();
//       if (_permissionGranted == location.PermissionStatus.denied) {
//         _permissionGranted = await _location.requestPermission();
//         if (_permissionGranted != location.PermissionStatus.granted) return;
//       }

//       final location.LocationData locationData = await _location.getLocation();
//       setState(() {
//         _currentLocation =
//             LatLng(locationData.latitude!, locationData.longitude!);
//       });

//       _location.onLocationChanged.listen((locationData) {
//         setState(() {
//           _currentLocation =
//               LatLng(locationData.latitude!, locationData.longitude!);
//           _updateCurrentLocationMarker();
//         });
//       });
//     } catch (e) {
//       print('Error initializing location: $e');
//     }
//   }

//   Future<void> _addMarkersAndFetchDirections() async {
//     try {
//       List<LatLng> pickupLocations = await _getCoordinates(widget.pickups);
//       List<LatLng> deliveryLocations = await _getCoordinates(widget.deliveries);

//       setState(() {
//         // Add markers for pickups
//         for (int i = 0; i < widget.pickups.length; i++) {
//           _markers.add(
//             Marker(
//               markerId: MarkerId('pickup_$i'),
//               position: pickupLocations[i],
//               infoWindow: InfoWindow(title: 'Pickup: ${widget.pickups[i]}'),
//               icon: BitmapDescriptor.defaultMarkerWithHue(
//                   BitmapDescriptor.hueGreen),
//             ),
//           );
//         }

//         // Add markers for deliveries
//         for (int i = 0; i < widget.deliveries.length; i++) {
//           _markers.add(
//             Marker(
//               markerId: MarkerId('delivery_$i'),
//               position: deliveryLocations[i],
//               infoWindow:
//                   InfoWindow(title: 'Delivery: ${widget.deliveries[i]}'),
//               icon: BitmapDescriptor.defaultMarkerWithHue(
//                   BitmapDescriptor.hueBlue),
//             ),
//           );
//         }
//       });

//       // Fetch directions and total distance
//       await _fetchDirectionsAndDistance(pickupLocations, deliveryLocations);

//       setState(() {
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error adding markers and fetching directions: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _fetchDirectionsAndDistance(
//       List<LatLng> pickups, List<LatLng> deliveries) async {
//     try {
//       // Use the first pickup and last delivery as the route endpoints
//       LatLng start = pickups.first;
//       LatLng end = deliveries.last;

//       // Google Directions API URL
//       String url =
//           'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&waypoints=${_formatWaypoints(pickups, deliveries)}&key=AIzaSyCZlAYZGHG2-FgU8CKOWjL-JqPpOVQdiXY';

//       // Fetch data from the API
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         // Decode polyline and add it to the map
//         String polyline = data['routes'][0]['overview_polyline']['points'];
//         List<LatLng> routeCoords = _decodePolyline(polyline);
//         setState(() {
//           _polylines.add(Polyline(
//             polylineId: const PolylineId('route'),
//             points: routeCoords,
//             color: Colors.blue,
//             width: 4,
//           ));
//         });

//         // Get total distance
//         String distance = data['routes'][0]['legs']
//             .map((leg) => leg['distance']['text'])
//             .join(", ");
//         setState(() {
//           _totalDistance = distance;
//         });
//       } else {
//         print('Failed to fetch directions: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching directions and distance: $e');
//     }
//   }

//   String _formatWaypoints(List<LatLng> pickups, List<LatLng> deliveries) {
//     List<String> waypoints = [
//       ...pickups.skip(1).map((loc) => '${loc.latitude},${loc.longitude}'),
//       ...deliveries.map((loc) => '${loc.latitude},${loc.longitude}'),
//     ];
//     return waypoints.join('|');
//   }

//   List<LatLng> _decodePolyline(String polyline) {
//     List<LatLng> points = [];
//     int index = 0, len = polyline.length;
//     int lat = 0, lng = 0;

//     while (index < len) {
//       int b, shift = 0, result = 0;
//       do {
//         b = polyline.codeUnitAt(index++) - 63;
//         result |= (b & 0x1F) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
//       lat += dlat;

//       shift = 0;
//       result = 0;
//       do {
//         b = polyline.codeUnitAt(index++) - 63;
//         result |= (b & 0x1F) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
//       lng += dlng;

//       points.add(LatLng(lat / 1E5, lng / 1E5));
//     }
//     return points;
//   }

//   Future<List<LatLng>> _getCoordinates(List<String> addresses) async {
//     List<Future<LatLng?>> futures = addresses.map((address) async {
//       try {
//         List<geocoding.Location> locations =
//             await geocoding.locationFromAddress(address);
//         return LatLng(locations.first.latitude, locations.first.longitude);
//       } catch (e) {
//         print('Error geocoding $address: $e');
//         return null;
//       }
//     }).toList();

//     return (await Future.wait(futures)).whereType<LatLng>().toList();
//   }

//   void _updateCurrentLocationMarker() {
//     if (_currentLocation != null) {
//       setState(() {
//         _markers.removeWhere((m) => m.markerId.value == 'current_location');
//         _markers.add(
//           Marker(
//             markerId: const MarkerId('current_location'),
//             position: _currentLocation!,
//             infoWindow: const InfoWindow(title: 'Your Location'),
//             icon:
//                 BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//           ),
//         );
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Path Details',
//           style: TextStyle(
//             color: Color.fromARGB(255, 252, 252,
//                 252), // Ensure text is visible on the dark background
//           ),
//         ),
//         backgroundColor: const Color.fromARGB(
//             255, 63, 63, 63), // Dark background for the AppBar
//         actions: [
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color.fromARGB(
//                     255, 252, 1, 1), // Bright red color for the button
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20), // Rounded edges
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 16), // Add padding for a better look
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => OrderFinishPage(
//                       totalDistance: _totalDistance,
//                     ),
//                   ),
//                 );
//               },
//               child: const Text(
//                 'Finish',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                   color: Colors.white, // White text for contrast
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Stack(
//               children: [
//                 GoogleMap(
//                   initialCameraPosition: CameraPosition(
//                     target: _currentLocation ?? _defaultLocation,
//                     zoom: 12,
//                   ),
//                   onMapCreated: (GoogleMapController controller) {
//                     mapController = controller;
//                   },
//                   markers: _markers,
//                   polylines: _polylines,
//                   myLocationEnabled: true,
//                 ),
//                 Positioned(
//                   top: 10,
//                   left: 10,
//                   right: 10,
//                   child: Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.2),
//                           blurRadius: 6,
//                         ),
//                       ],
//                     ),
//                     child: Text(
//                       'Total Distance: $_totalDistance',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }
