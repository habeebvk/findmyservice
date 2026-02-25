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
  LatLng? searchedLocation;
  Set<Marker> markers = {};
  final Location location = Location();
  final TextEditingController _searchController = TextEditingController();
  String _selectedPlaceType = "";

  final List<Map<String, dynamic>> _placeTypes = [
    {"name": "Temples", "type": "hindu_temple", "icon": Icons.temple_hindu},
    {"name": "Churches", "type": "church", "icon": Icons.church},
    {"name": "Schools", "type": "school", "icon": Icons.school},
    {"name": "Hospitals", "type": "hospital", "icon": Icons.local_hospital},
    {"name": "Mosques", "type": "mosque", "icon": Icons.mosque},
    {"name": "Banks", "type": "bank", "icon": Icons.account_balance},
    {"name": "Parks", "type": "park", "icon": Icons.park},
    {"name": "Restaurants", "type": "restaurant", "icon": Icons.restaurant},
  ];

  @override
  void initState() {
    super.initState();
    _selectedPlaceType = widget.placeType;
    _getLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

    LocationData data = await location.getLocation();

    setState(() {
      currentLocation = LatLng(data.latitude!, data.longitude!);
    });

    _fetchNearbyPlaces();
  }

  /// 🔍 Search Location using Geocoding API
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    const String apiKey = "AIzaSyCnXk2YpbWjr5UgTFFflUgfDsagIqwwObE";
    final url =
        "https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(query)}&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["results"] != null && data["results"].isNotEmpty) {
          final loc = data["results"][0]["geometry"]["location"];
          LatLng pos = LatLng(loc["lat"], loc["lng"]);

          setState(() {
            searchedLocation = pos;
          });

          mapController?.animateCamera(CameraUpdate.newLatLngZoom(pos, 14));
          _fetchNearbyPlaces(targetLatLng: pos);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Location not found")));
          }
        }
      }
    } catch (e) {
      debugPrint("Error searching location: $e");
    }
  }

  /// 🔍 Fetch Nearby Places using Google Places API
  Future<void> _fetchNearbyPlaces({LatLng? targetLatLng}) async {
    LatLng targetLocation =
        targetLatLng ??
        searchedLocation ??
        currentLocation ??
        const LatLng(0, 0);
    if (targetLocation.latitude == 0) return;

    String type = _convertPlaceType(_selectedPlaceType);
    const String apiKey = "AIzaSyCnXk2YpbWjr5UgTFFflUgfDsagIqwwObE";

    final url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        "?location=${targetLocation.latitude},${targetLocation.longitude}"
        "&radius=3000&type=$type&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["results"] != null) {
          markers.clear();

          // Add a special marker for searched location if it exists
          if (searchedLocation != null) {
            markers.add(
              Marker(
                markerId: MarkerId("searched_location"),
                position: searchedLocation!,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure,
                ),
                infoWindow: InfoWindow(title: "Searched Location"),
              ),
            );
          }

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

          // Move camera to show results if explicitly asked (not handled here anymore as it might be annoying)
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
      case "Parks":
        return "park";
      case "Restaurants":
        return "restaurant";
      default:
        return "point_of_interest";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allow map to go behind app bar if needed
      appBar: AppBar(
        title: Text("${_selectedPlaceType} Nearby"),
        backgroundColor: Colors.white.withOpacity(0.9),
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // 1. Map (Occupies full space)
                Positioned.fill(
                  child: GoogleMap(
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    padding: EdgeInsets.only(
                      top: 160,
                      bottom: 20,
                    ), // Move internal map UI
                    initialCameraPosition: CameraPosition(
                      target: currentLocation!,
                      zoom: 14,
                    ),
                    markers: markers,
                    onMapCreated: (controller) => mapController = controller,
                  ),
                ),

                // 2. Search Bar and Chips (Floating on top)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      15,
                      20,
                      15,
                      0,
                    ), // Push below AppBar
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Floating Search Bar
                        Material(
                          elevation: 8,
                          shadowColor: Colors.black45,
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(color: Colors.black87),
                              decoration: InputDecoration(
                                hintText: "Search location...",
                                hintStyle: TextStyle(color: Colors.grey),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.orange,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      searchedLocation = null;
                                    });
                                    _fetchNearbyPlaces(
                                      targetLatLng: currentLocation,
                                    );
                                    mapController?.animateCamera(
                                      CameraUpdate.newLatLngZoom(
                                        currentLocation!,
                                        14,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              onSubmitted: (value) => _searchLocation(value),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),

                        // Horizontal Category Scroll
                        Container(
                          height: 700,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _placeTypes.length,
                            itemBuilder: (context, index) {
                              final place = _placeTypes[index];
                              bool isSelected =
                                  _selectedPlaceType == place["name"];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0,bottom: 650),
                                child: FilterChip(
                                  label: Text(place["name"]),
                                  avatar: Icon(
                                    place["icon"],
                                    size: 18,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.orange,
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedPlaceType = place["name"];
                                    });
                                    _fetchNearbyPlaces();
                                  },
                                  selectedColor: Colors.orange,
                                  checkmarkColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  backgroundColor: Colors.white.withOpacity(
                                    0.9,
                                  ),
                                  elevation: 4,
                                  pressElevation: 6,
                                  shadowColor: Colors.black26,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    side: BorderSide(
                                      color: isSelected
                                          ? Colors.orange
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
