import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class NearbyPlacesMap extends StatefulWidget {
  final String placeType;
  NearbyPlacesMap({required this.placeType});

  @override
  _NearbyPlacesMapState createState() => _NearbyPlacesMapState();
}

class _NearbyPlacesMapState extends State<NearbyPlacesMap> {
  GoogleMapController? mapController;
  LatLng? currentLocation;
  Set<Marker> markers = {};
  final Location location = Location();

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  /// 📍 GET LOCATION (Without Geolocator)
  Future<void> _getLocation() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) return;
    }

    LocationData data = await location.getLocation(); // ✔ FIXED

    setState(() {
      currentLocation = LatLng(data.latitude!, data.longitude!);
    });

    _fetchNearbyPlaces();
  }

  /// 🔍 Fetch Nearby Places using Google Places API
  Future<void> _fetchNearbyPlaces() async {
    if (currentLocation == null) return;

    String type = _convertPlaceType(widget.placeType);
    const String apiKey = "AIzaSyCnXk2YpbWjr5UgTFFflUgfDsagIqwwObE";

    final url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        "?location=${currentLocation!.latitude},${currentLocation!.longitude}"
        "&radius=3000&type=$type&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["results"] != null) {
          markers.clear();

          for (var place in data["results"]) {
            LatLng pos = LatLng(
              place["geometry"]["location"]["lat"],
              place["geometry"]["location"]["lng"],
            );

            markers.add(
              Marker(
                markerId: MarkerId(place["place_id"] ?? place["name"]),
                position: pos,
                infoWindow: InfoWindow(
                  title: place["name"],
                  snippet: place["vicinity"],
                ),
              ),
            );
          }

          setState(() {});

          // Move camera to show markers if any
          if (markers.isNotEmpty && mapController != null) {
            mapController!.animateCamera(
              CameraUpdate.newLatLng(currentLocation!),
            );
          }
        }
      } else {
        debugPrint("API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Error fetching nearby places: $e");
    }
  }

  /// 🔄 Convert Card Name to Google API Place Type
  String _convertPlaceType(String type) {
    switch (type) {
      case "Temples":
        return "hindu_temple";
      case "Churches":
        return "church";
      case "Hospitals":
        return "hospital";
      case "Schools":
        return "school";
      case "Mosques":
        return "mosque";
      case "Banks":
        return "bank";
      default:
        return "point_of_interest";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.placeType} Nearby")),
      body: currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              initialCameraPosition: CameraPosition(
                target: currentLocation!,
                zoom: 14,
              ),
              markers: markers,
              onMapCreated: (controller) => mapController = controller,
            ),
    );
  }
}
