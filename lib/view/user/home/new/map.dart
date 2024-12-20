import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleMapPage extends StatefulWidget {
  @override
  _GoogleMapPageState createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  late GoogleMapController _controller;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  LatLng _currentPosition = LatLng(9.319611, 80.722254); // Default location
  final Location _location = Location();

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _getUserLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPath();
    });
  }

  Future<void> _getUserLocation() async {
    var userLocation = await _location.getLocation();
    setState(() {
      _currentPosition =
          LatLng(userLocation.latitude!, userLocation.longitude!);
    });
    _moveCamera(_currentPosition);
  }

  void _moveCamera(LatLng position) {
    _controller.animateCamera(CameraUpdate.newLatLngZoom(position, 14));
  }

  Future<LatLng> _getLatLngFromAddress(String address) async {
    final String apiKey = "AIzaSyCZlAYZGHG2-FgU8CKOWjL-JqPpOVQdiXY";
    final String url =
        "https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        return LatLng(location['lat'], location['lng']);
      } else {
        throw Exception("No location found for address: $address");
      }
    } else {
      throw Exception("Error fetching location: ${response.reasonPhrase}");
    }
  }

  Future<List<LatLng>> _fetchAddresses() async {
    List<String> addresses = [
      "Mullaitivu Beach",
      "Iranaipalai Roman Catholic School",
      "NWSDB OIC Office, Puthukkudiyiruppu",
    ];

    List<LatLng> locations = [];
    for (String address in addresses) {
      try {
        LatLng location = await _getLatLngFromAddress(address);
        locations.add(location);
      } catch (e) {
        print(e);
      }
    }
    return locations;
  }

  Future<void> _getDirections(LatLng start, LatLng end) async {
    final String apiKey = "AIzaSyCZlAYZGHG2-FgU8CKOWjL-JqPpOVQdiXY";
    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["routes"].isNotEmpty) {
        final route = data["routes"][0];
        final points = route["overview_polyline"]["points"];

        // Extract total distance and duration
        final legs = route["legs"];
        double totalDistance = 0.0; // Use double for distances
        int totalDuration = 0; // Use int for duration

        for (var leg in legs) {
          // Safely cast to double for distance and int for duration
          totalDistance += (leg["distance"]["value"] as num)
              .toDouble(); // in meters (double)
          totalDuration +=
              (leg["duration"]["value"] as int); // in seconds (int)
        }

        // Convert meters to kilometers
        totalDistance /= 1000; // Convert to kilometers (double)
        final durationInMinutes = totalDuration ~/ 60;
        final hours = durationInMinutes ~/ 60;
        final minutes = durationInMinutes % 60;

        // Display total distance and time
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Total Distance: ${totalDistance.toStringAsFixed(2)} km, Time: ${hours}h ${minutes}m"),
          ),
        );

        // Add the polyline to the map
        _addPolyline(points);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No routes found between $start and $end.")),
        );
      }
    } else {
      print("Error fetching directions: ${response.reasonPhrase}");
    }
  }

  void _addPolyline(String encodedPolyline) {
    final List<LatLng> polylinePoints = _decodePolyline(encodedPolyline);
    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId("route_${_polylines.length}"),
          points: polylinePoints,
          color: Colors.blue,
          width: 5,
        ),
      );
    });
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  Future<void> _showPath() async {
    try {
      List<LatLng> locations = await _fetchAddresses();

      if (locations.isNotEmpty) {
        setState(() {
          _markers.clear();
          for (LatLng location in locations) {
            _markers.add(
              Marker(
                markerId: MarkerId(location.toString()),
                position: location,
                infoWindow: InfoWindow(
                  title: "Location",
                  snippet:
                      "Lat: ${location.latitude}, Lng: ${location.longitude}",
                ),
              ),
            );
          }
        });

        for (int i = 0; i < locations.length - 1; i++) {
          await _getDirections(locations[i], locations[i + 1]);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unable to fetch locations.")),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Maps Flutter"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 10,
              ),
              mapType: MapType.normal,
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.directions),
        onPressed: _showPath,
      ),
    );
  }
}
