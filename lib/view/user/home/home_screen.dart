import 'package:findmyservicesapp/view/user/category/worker_list.dart';
import 'package:findmyservicesapp/view/user/home/nearbyplaces.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/database_service.dart';
import '../../../model/user_request.dart';
import '../../../services/auth_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> categories = [
    {"title": "Carpentry", "icon": Icons.handyman, "color": Colors.brown},
    {"title": "Plumbing", "icon": Icons.plumbing, "color": Colors.blue},
    {
      "title": "Electricals",
      "icon": Icons.electrical_services,
      "color": Colors.yellow,
    },
    {
      "title": "Painting",
      "icon": Icons.imagesearch_roller_sharp,
      "color": Colors.red,
    },
    {"title": "Pest Care", "icon": Icons.bug_report, "color": Colors.green},
    {
      "title": "Cleaning",
      "icon": Icons.cleaning_services,
      "color": Colors.purple,
    },
    {"title": "Gardening", "icon": Icons.grass, "color": Colors.lightGreen},
    {"title": "Glass Repair", "icon": Icons.window, "color": Colors.cyan},
    {"title": "Welding", "icon": Icons.format_paint, "color": Colors.orange},
    {"title": "Mechanic", "icon": Icons.settings, "color": Colors.blueGrey},
  ];

  final List<Map<String, dynamic>> offers = [
    {
      "title": "15% Off",
      "subtitle": "Sunday Special",
      "description": "Unlock exclusive savings\non all your services",
      "gradient": [Colors.orange.shade600, Colors.orange.shade400],
      "icon": Icons.local_offer,
    },
    {
      "title": "20% Off",
      "subtitle": "New User Offer",
      "description": "First time booking?\nGet amazing discounts!",
      "gradient": [Colors.purple.shade600, Colors.purple.shade400],
      "icon": Icons.person_add,
    },
    {
      "title": "Buy 2 Get 1",
      "subtitle": "Mega Deal",
      "description": "Book multiple services\nand save more money",
      "gradient": [Colors.green.shade600, Colors.green.shade400],
      "icon": Icons.shopping_cart,
    },
    {
      "title": "Free Delivery",
      "subtitle": "Weekend Special",
      "description": "No delivery charges\nfor weekend bookings",
      "gradient": [Colors.blue.shade600, Colors.blue.shade400],
      "icon": Icons.delivery_dining,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll carousel
    Future.delayed(Duration(seconds: 3), _autoScroll);
  }

  void showNearbyPlaces(BuildContext context) async {
    const url = 'https://www.google.com/maps/search/nearby+places/';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _autoScroll() {
    if (mounted) {
      if (_currentPage < offers.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }

      Future.delayed(Duration(seconds: 3), _autoScroll);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade400, Colors.orange.shade200],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              'Search',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              Icons.tune,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Carousel Slider for Special Offers
                  Text(
                    'Special Offers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    height: 150,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemCount: offers.length,
                          itemBuilder: (context, index) {
                            final offer = offers[index];
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: offer['gradient'],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 15,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            offer['title'],
                                            style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            offer['subtitle'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            offer['description'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                      child: Icon(
                                        offer['icon'],
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        // Page indicators
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: offers.asMap().entries.map((entry) {
                              return Container(
                                width: 8.0,
                                height: 8.0,
                                margin: EdgeInsets.symmetric(horizontal: 4.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentPage == entry.key
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.4),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),

                  // Quick Actions (Taxi & Nearby Places)
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          'Book GoodsTaxi',
                          Icons.local_taxi,
                          Colors.green,
                          () => _showTaxiBooking(context),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _buildQuickActionCard(
                          'Nearby Places',
                          Icons.location_on,
                          Colors.blue,
                          () => _showNearbyPlaces(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),

                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: .7,
                        crossAxisCount: 4,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final item = categories[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ServiceList(role: item["title"]),
                              ),
                            );
                          },
                          child: _buildCategoryItem(
                            item["title"],
                            item["icon"],
                            item["color"],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showTaxiBooking(BuildContext context) {
    final fromController = TextEditingController();
    final toController = TextEditingController();
    final distanceController = TextEditingController();
    String selectedVehicle = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        double distanceKm = 0;
        double rate = 0;
        double totalAmount = 0;

        return StatefulBuilder(
          builder: (context, setState) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Book GoodsTaxi',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  _buildLocationField(
                    'From',
                    'Current Location',
                    Icons.my_location,
                    fromController,
                  ),
                  SizedBox(height: 15),
                  _buildLocationField(
                    'To',
                    'Where to?',
                    Icons.location_on,
                    toController,
                  ),
                  SizedBox(height: 20),

                  // Distance Input
                  Text(
                    'Distance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: distanceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Enter Distance (KM)",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(Icons.route, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        distanceKm = double.tryParse(value) ?? 0;
                        setState(() => totalAmount = distanceKm * rate);
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Vehicle Type',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: _buildVehicleOption(
                          'Car',
                          Icons.directions_car,
                          '₹120 / KM',
                          selectedVehicle == 'Car',
                          () {
                            setState(() {
                              selectedVehicle = 'Car';
                              rate = 120;
                              totalAmount = distanceKm * rate;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: _buildVehicleOption(
                          'Bike',
                          Icons.two_wheeler,
                          '₹50 / KM',
                          selectedVehicle == 'Bike',
                          () {
                            setState(() {
                              selectedVehicle = 'Bike';
                              rate = 50;
                              totalAmount = distanceKm * rate;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: _buildVehicleOption(
                          'Auto',
                          Icons.agriculture,
                          '₹80 / KM',
                          selectedVehicle == 'Auto',
                          () {
                            setState(() {
                              selectedVehicle = 'Auto';
                              rate = 80;
                              totalAmount = distanceKm * rate;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 25),

                  // Display Total
                  Center(
                    child: Text(
                      "Total Amount: ₹${totalAmount.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),

                  Spacer(),

                  // Book Now Button
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          if (selectedVehicle.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select a vehicle type"),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          if (toController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter destination"),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          if (distanceKm <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter valid distance"),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          final databaseService = DatabaseService();
                          final request = UserRequest(
                            service: 'Taxi Booking',
                            workerName: 'Pending Assignment',
                            customerName:
                                AuthService().currentUser?.name ?? "Guest User",
                            requestDate: DateTime.now().toString().split(
                              '.',
                            )[0],
                            status: 'pending',
                            price: totalAmount.toInt(),
                            description:
                                'Taxi booking: ${fromController.text} to ${toController.text} via $selectedVehicle ($distanceKm km)',
                          );

                          await databaseService.insertBooking(
                            request,
                            role: 'taxi',
                          );

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Taxi booked successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error booking taxi: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Book Now',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // void _showTaxiBooking(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => Container(
  //       height: MediaQuery.of(context).size.height * 0.7,
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
  //       ),
  //       child: Padding(
  //         padding: EdgeInsets.all(20),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Center(
  //               child: Container(
  //                 width: 50,
  //                 height: 5,
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey.shade300,
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //               ),
  //             ),
  //             SizedBox(height: 20),
  //             Text(
  //               'Book GoodsTaxi',
  //               style: TextStyle(
  //                 fontSize: 24,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             SizedBox(height: 20),
  //             _buildLocationField('From', 'Current Location', Icons.my_location),
  //             SizedBox(height: 15),
  //             _buildLocationField('To', 'Where to?', Icons.location_on),
  //             SizedBox(height: 30),
  //             Text(
  //               'Vehicle Type',
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             SizedBox(height: 15),

  //             Row(
  //               children: [
  //                 Expanded(child: _buildVehicleOption('Car', Icons.directions_car, '₹120')),
  //                 SizedBox(width: 15),
  //                 Expanded(child: _buildVehicleOption('Bike', Icons.two_wheeler, '₹50')),
  //                 SizedBox(width: 15),
  //                 Expanded(child: _buildVehicleOption('Auto', Icons.agriculture, '₹80')),
  //               ],
  //             ),
  //             Spacer(),
  //             Container(
  //               width: double.infinity,
  //               child: ElevatedButton(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(content: Text('Taxi booked successfully!')),
  //                   );
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors.orange,
  //                   padding: EdgeInsets.symmetric(vertical: 15),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(15),
  //                   ),
  //                 ),
  //                 child: Text(
  //                   'Book Now',
  //                   style: TextStyle(fontSize: 18, color: Colors.white),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  _showNearbyPlaces(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Nearby Places',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  children: [
                    _buildNearbyPlaceCard(
                      'Temples',
                      Icons.temple_hindu,
                      Colors.orange,
                    ),
                    _buildNearbyPlaceCard(
                      'Churches',
                      Icons.church,
                      Colors.blue,
                    ),
                    _buildNearbyPlaceCard(
                      'Hospitals',
                      Icons.local_hospital,
                      Colors.red,
                    ),
                    _buildNearbyPlaceCard(
                      'Schools',
                      Icons.school,
                      Colors.green,
                    ),
                    _buildNearbyPlaceCard('Mosques', Icons.mosque, Colors.teal),
                    _buildNearbyPlaceCard(
                      'Banks',
                      Icons.account_balance,
                      Colors.purple,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationField(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              prefixIcon: Icon(icon, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleOption(
    String name,
    IconData icon,
    String price,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.orange.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: isSelected ? Colors.orange : Colors.grey,
            ),
            SizedBox(height: 5),
            Text(
              name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            Text(
              price,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyPlaceCard(String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NearbyPlacesMap(placeType: title)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 35),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}












// import 'package:flutter/material.dart';



// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: Container(
//         height: double.infinity,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.orange.shade400, Colors.orange.shade200],
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header
//                   // Row(
//                   //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   //   children: [
//                   //     Icon(Icons.menu, color: Colors.white, size: 28),
//                   //     Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
//                   //   ],
//                   // ),
//                   // SizedBox(height: 30),
                  
//                   // Location
//                   // Text(
//                   //   'Location',
//                   //   style: TextStyle(
//                   //     fontSize: 24,
//                   //     fontWeight: FontWeight.bold,
//                   //     color: Colors.white,
//                   //   ),
//                   // ),
//                   // Row(
//                   //   children: [
//                   //     Text(
//                   //       'Zilker, Austin',
//                   //       style: TextStyle(
//                   //         fontSize: 16,
//                   //         color: Colors.white70,
//                   //       ),
//                   //     ),
//                   //     Icon(Icons.keyboard_arrow_down, color: Colors.white70),
//                   //   ],
//                   // ),
//                   // SizedBox(height: 25),
                  
//                   // Search Bar
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(25),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 10,
//                           offset: Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.search, color: Colors.grey),
//                         SizedBox(width: 15),
//                         Expanded(
//                           child: Text(
//                             'Search',
//                             style: TextStyle(color: Colors.grey, fontSize: 16),
//                           ),
//                         ),
//                         Container(
//                           padding: EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.orange,
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                           child: Icon(Icons.tune, color: Colors.white, size: 20),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 10),
                  
//                   // Special Offers
//                   Text(
//                     'Special Offers',
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   SizedBox(height: 15),
//                   Container(
//                     height: 150,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [Colors.orange.shade600, Colors.orange.shade400],
//                       ),
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black26,
//                           blurRadius: 15,
//                           offset: Offset(0, 8),
//                         ),
//                       ],
//                     ),
//                     child: Padding(
//                       padding: EdgeInsets.all(20),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   '15% Off',
//                                   style: TextStyle(
//                                     fontSize: 30,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 Text(
//                                   'Sunday Special',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 SizedBox(height: 8),
//                                 Text(
//                                   'Unlock exclusive savings\non all your services',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.white70,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Container(
//                             width: 80,
//                             height: 80,
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(40),
//                             ),
//                             child: Icon(
//                               Icons.person,
//                               color: Colors.white,
//                               size: 40,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 30),
                  
//                   // Quick Actions (Taxi & Nearby Places)
//                   Text(
//                     'Quick Actions',
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   SizedBox(height: 15),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _buildQuickActionCard(
//                           'Book GoodsTaxi',
//                           Icons.local_taxi,
//                           Colors.green,
//                           () => _showTaxiBooking(context),
//                         ),
//                       ),
//                       SizedBox(width: 15),
//                       Expanded(
//                         child: _buildQuickActionCard(
//                           'Nearby Places',
//                           Icons.location_on,
//                           Colors.blue,
//                           () => _showNearbyPlaces(context),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 30),
                  
//                   // Categories
//                   Text(
//                     'Categories',
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   SizedBox(height: 15),
//                   Container(
//                     padding: EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 15,
//                           offset: Offset(0, 8),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             _buildCategoryItem('Carpentry', Icons.handyman, Colors.brown),
//                             _buildCategoryItem('Plumbing', Icons.plumbing, Colors.blue),
//                             _buildCategoryItem('Electricals', Icons.electrical_services, Colors.yellow),
//                             _buildCategoryItem('Appliances', Icons.kitchen, Colors.red),
//                           ],
//                         ),
//                         SizedBox(height: 20),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             _buildCategoryItem('Pest Care', Icons.bug_report, Colors.green),
//                             _buildCategoryItem('Cleaning', Icons.cleaning_services, Colors.purple),
//                             _buildCategoryItem('Gardening', Icons.grass, Colors.lightGreen),
//                             _buildCategoryItem('Glass Shine', Icons.window, Colors.cyan),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 30),
                  
//                   // Popular Specialists
//                   // Text(
//                   //   'Popular Specialists',
//                   //   style: TextStyle(
//                   //     fontSize: 22,
//                   //     fontWeight: FontWeight.bold,
//                   //     color: Colors.white,
//                   //   ),
//                   // ),
//                   // SizedBox(height: 15),
//                   // Container(
//                   //   padding: EdgeInsets.all(20),
//                   //   decoration: BoxDecoration(
//                   //     color: Colors.white,
//                   //     borderRadius: BorderRadius.circular(20),
//                   //     boxShadow: [
//                   //       BoxShadow(
//                   //         color: Colors.black12,
//                   //         blurRadius: 15,
//                   //         offset: Offset(0, 8),
//                   //       ),
//                   //     ],
//                   //   ),
//                   //   child: Row(
//                   //     children: [
//                   //       CircleAvatar(
//                   //         radius: 30,
//                   //         backgroundColor: Colors.grey.shade300,
//                   //         child: Icon(Icons.person, size: 30, color: Colors.grey),
//                   //       ),
//                   //       SizedBox(width: 15),
//                   //       Expanded(
//                   //         child: Column(
//                   //           crossAxisAlignment: CrossAxisAlignment.start,
//                   //           children: [
//                   //             Row(
//                   //               children: [
//                   //                 Icon(Icons.star, color: Colors.amber, size: 20),
//                   //                 Text(
//                   //                   ' 4.1',
//                   //                   style: TextStyle(fontWeight: FontWeight.bold),
//                   //                 ),
//                   //               ],
//                   //             ),
//                   //             SizedBox(height: 5),
//                   //             Text(
//                   //               'Home Appliances',
//                   //               style: TextStyle(
//                   //                 fontSize: 16,
//                   //                 fontWeight: FontWeight.w500,
//                   //               ),
//                   //             ),
//                   //           ],
//                   //         ),
//                   //       ),
//                   //       Icon(Icons.arrow_forward_ios, color: Colors.grey),
//                   //     ],
//                   //   ),
//                   // ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
  
//   Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 10,
//               offset: Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Container(
//               padding: EdgeInsets.all(15),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, color: color, size: 30),
//             ),
//             SizedBox(height: 10),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black87,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildCategoryItem(String title, IconData icon, Color color) {
//     return Column(
//       children: [
//         Container(
//           padding: EdgeInsets.all(15),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(15),
//           ),
//           child: Icon(icon, color: color, size: 30),
//         ),
//         SizedBox(height: 8),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }
  
//   void _showTaxiBooking(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: MediaQuery.of(context).size.height * 0.7,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                   width: 50,
//                   height: 5,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Text(
//                 'Book GoodsTaxi',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 20),
//               _buildLocationField('From', 'Current Location', Icons.my_location),
//               SizedBox(height: 15),
//               _buildLocationField('To', 'Where to?', Icons.location_on),
//               SizedBox(height: 30),
//               Text(
//                 'Vehicle Type',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 15),
//               Row(
//                 children: [
//                   Expanded(child: _buildVehicleOption('Car', Icons.directions_car, '₹120')),
//                   SizedBox(width: 15),
//                   Expanded(child: _buildVehicleOption('Bike', Icons.two_wheeler, '₹50')),
//                   SizedBox(width: 15),
//                   Expanded(child: _buildVehicleOption('Auto', Icons.agriculture, '₹80')),
//                 ],
//               ),
//               Spacer(),
//               Container(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Taxi booked successfully!')),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     padding: EdgeInsets.symmetric(vertical: 15),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                   ),
//                   child: Text(
//                     'Book Now',
//                     style: TextStyle(fontSize: 18, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
  
//   void _showNearbyPlaces(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: MediaQuery.of(context).size.height * 0.7,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                   width: 50,
//                   height: 5,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Text(
//                 'Nearby Places',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 20),
//               Expanded(
//                 child: GridView.count(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 15,
//                   mainAxisSpacing: 15,
//                   children: [
//                     _buildNearbyPlaceCard('Temples', Icons.temple_hindu, Colors.orange),
//                     _buildNearbyPlaceCard('Churches', Icons.church, Colors.blue),
//                     _buildNearbyPlaceCard('Hospitals', Icons.local_hospital, Colors.red),
//                     _buildNearbyPlaceCard('Schools', Icons.school, Colors.green),
//                     _buildNearbyPlaceCard('Mosques', Icons.mosque, Colors.teal),
//                     _buildNearbyPlaceCard('Banks', Icons.account_balance, Colors.purple),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
  
//   Widget _buildLocationField(String label, String hint, IconData icon) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         SizedBox(height: 8),
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Row(
//             children: [
//               Icon(icon, color: Colors.grey),
//               SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   hint,
//                   style: TextStyle(
//                     color: Colors.grey.shade600,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
  
//   Widget _buildVehicleOption(String name, IconData icon, String price) {
//     return Container(
//       padding: EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, size: 30, color: Colors.orange),
//           SizedBox(height: 5),
//           Text(
//             name,
//             style: TextStyle(fontWeight: FontWeight.w500),
//           ),
//           Text(
//             price,
//             style: TextStyle(
//               color: Colors.grey.shade600,
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildNearbyPlaceCard(String title, IconData icon, Color color) {
//     return Container(
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 40, color: color),
//           SizedBox(height: 10),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }