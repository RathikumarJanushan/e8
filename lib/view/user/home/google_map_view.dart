// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:workmanager/workmanager.dart';

// class GoogleMapView extends StatefulWidget {
//   @override
//   _GoogleMapViewState createState() => _GoogleMapViewState();
// }

// class _GoogleMapViewState extends State<GoogleMapView> {
//   final Location _locationService = Location();
//   GoogleMapController? _mapController;
//   LatLng? _currentPosition;
//   Timer? _debounceTimer;
//   Set<Marker> _markers = {};

//   @override
//   void initState() {
//     super.initState();
//     _initializeLocationService();
//     _loadLocationsFromFirestore();
//   }

//   Future<void> _initializeLocationService() async {
//     bool serviceEnabled = await _locationService.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await _locationService.requestService();
//       if (!serviceEnabled) return;
//     }

//     PermissionStatus permissionGranted = await _locationService.hasPermission();
//     if (permissionGranted == PermissionStatus.denied) {
//       permissionGranted = await _locationService.requestPermission();
//       if (permissionGranted != PermissionStatus.granted) return;
//     }

//     _startBackgroundLocationUpdates();
//     _updateLocation();
//   }

//   void _startBackgroundLocationUpdates() {
//     Workmanager().initialize(
//       callbackDispatcher,
//       isInDebugMode: true, // Set to false in production
//     );
//     Workmanager().registerPeriodicTask(
//       "locationUpdateTask",
//       "locationUpdateTask",
//       frequency: Duration(minutes: 15),
//     );
//   }

//   static void callbackDispatcher() {
//     Workmanager().executeTask((task, inputData) async {
//       final location = Location();
//       final FirebaseAuth auth = FirebaseAuth.instance;
//       final user = auth.currentUser;

//       if (user != null) {
//         LocationData locationData = await location.getLocation();
//         await FirebaseFirestore.instance
//             .collection('user_locations')
//             .doc(user.uid)
//             .set({
//           'latitude': locationData.latitude,
//           'longitude': locationData.longitude,
//           'userId': user.uid,
//           'UserStatus': 'waiting',
//         });
//       }

//       return Future.value(true);
//     });
//   }

//   Future<void> _updateLocation() async {
//     _locationService.onLocationChanged.listen((LocationData locationData) {
//       if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();

//       _debounceTimer = Timer(Duration(seconds: 5), () async {
//         if (!mounted) return;

//         LatLng newPosition =
//             LatLng(locationData.latitude!, locationData.longitude!);
//         setState(() {
//           _currentPosition = newPosition;
//         });

//         final userId = FirebaseAuth.instance.currentUser?.uid;
//         if (userId != null) {
//           await FirebaseFirestore.instance
//               .collection('user_locations')
//               .doc(userId)
//               .set({
//             'latitude': locationData.latitude,
//             'longitude': locationData.longitude,
//             'userId': userId,
//             'UserStatus': 'waiting',
//           });
//         }

//         if (_mapController != null) {
//           _mapController!.animateCamera(CameraUpdate.newLatLng(newPosition));
//         }
//       });
//     });
//   }

//   Future<void> _loadLocationsFromFirestore() async {
//     final userId = FirebaseAuth.instance.currentUser?.uid;
//     if (userId != null) {
//       final ordersSnapshot = await FirebaseFirestore.instance
//           .collection('order')
//           .where('userId', isEqualTo: userId)
//           .get();

//       Set<Marker> markers = {};
//       for (var order in ordersSnapshot.docs) {
//         final locations = order['locations'] as List<dynamic>? ?? [];
//         for (var locationMap in locations) {
//           final description = locationMap['description'] ?? 'No Description';
//           final location = locationMap['location'] ?? 'Unknown Location';
//           // Assume you have latitude and longitude stored or fetched for each location
//           final lat = locationMap['latitude'] as double?;
//           final lng = locationMap['longitude'] as double?;

//           if (lat != null && lng != null) {
//             markers.add(
//               Marker(
//                 markerId: MarkerId(location),
//                 position: LatLng(lat, lng),
//                 infoWindow: InfoWindow(
//                   title: location,
//                   snippet: description,
//                 ),
//                 icon: BitmapDescriptor.defaultMarkerWithHue(
//                     BitmapDescriptor.hueAzure),
//               ),
//             );
//           }
//         }
//       }

//       setState(() {
//         _markers = markers;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _currentPosition != null
//         ? Stack(
//             children: [
//               GoogleMap(
//                 initialCameraPosition: CameraPosition(
//                   target: _currentPosition!,
//                   zoom: 14,
//                 ),
//                 onMapCreated: (GoogleMapController controller) {
//                   _mapController = controller;
//                 },
//                 myLocationEnabled: true,
//                 myLocationButtonEnabled: true,
//                 zoomControlsEnabled: false,
//                 markers: _markers,
//               ),
//               Positioned(
//                 top: 10,
//                 right: 10,
//                 child: IconButton(
//                   icon: Icon(
//                     Icons.fullscreen,
//                     color: Colors.white,
//                     size: 30,
//                   ),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) =>
//                             FullScreenMap(currentPosition: _currentPosition!),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           )
//         : Center(child: CircularProgressIndicator());
//   }
// }

// class FullScreenMap extends StatelessWidget {
//   final LatLng currentPosition;

//   FullScreenMap({required this.currentPosition});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Full Screen Map'),
//       ),
//       body: GoogleMap(
//         initialCameraPosition: CameraPosition(
//           target: currentPosition,
//           zoom: 14,
//         ),
//         myLocationEnabled: true,
//         myLocationButtonEnabled: true,
//         zoomControlsEnabled: true,
//       ),
//     );
//   }
// }
