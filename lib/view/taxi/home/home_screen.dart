import 'package:flutter/material.dart';
import '../../../services/database_service.dart';
import '../../../model/user_request.dart';
import '../../../services/auth_service.dart';

class GoodsTaxiOwnerHomePage extends StatefulWidget {
  const GoodsTaxiOwnerHomePage({Key? key}) : super(key: key);

  @override
  State<GoodsTaxiOwnerHomePage> createState() => _GoodsTaxiOwnerHomePageState();
}

class _GoodsTaxiOwnerHomePageState extends State<GoodsTaxiOwnerHomePage> {
  final DatabaseService _databaseService = DatabaseService();
  List<BookingRequest> requests = [];
  List<BookingRequest> acceptedRequests = [];
  List<BookingRequest> rejectedRequests = [];
  bool _isLoading = false;

  int acceptedCount = 0;
  int rejectedCount = 0;
  double todayEarnings = 0.0;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final workType = AuthService().currentUser?.workType ?? 'taxi';
      final allBookings = await _databaseService.getBookings(role: workType);
      setState(() {
        // Filter for taxi/goods services
        final taxiBookings = allBookings
            .where(
              (b) =>
                  b.service.toLowerCase().contains('taxi') ||
                  b.service.toLowerCase().contains('goods'),
            )
            .toList();

        requests = taxiBookings
            .where((b) => b.status.toLowerCase() == 'pending')
            .map((b) => _mapToBookingRequest(b))
            .toList();

        acceptedRequests = taxiBookings
            .where((b) => b.status.toLowerCase() == 'accepted')
            .map((b) => _mapToBookingRequest(b))
            .toList();

        rejectedRequests = taxiBookings
            .where(
              (b) =>
                  b.status.toLowerCase() == 'rejected' ||
                  b.status.toLowerCase() == 'completed',
            )
            .map((b) => _mapToBookingRequest(b))
            .toList();

        acceptedCount = acceptedRequests.length;
        rejectedCount = rejectedRequests.length;
        todayEarnings = 0.0;
        for (var request in acceptedRequests) {
          try {
            final fareValue = request.fare.replaceAll(RegExp(r'[^\d.]'), '');
            todayEarnings += double.tryParse(fareValue) ?? 0.0;
          } catch (e) {
            debugPrint("Error parsing fare: ${request.fare}");
          }
        }
      });
    } catch (e) {
      debugPrint("Error loading taxi requests: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  BookingRequest _mapToBookingRequest(UserRequest b) {
    // Expected format: 'Taxi booking: From to To via Vehicle (Distance km)'
    String pickup = "Unknown";
    String dropoff = "Unknown";
    String distance = "N/A";
    String vehicle = "Taxi";

    try {
      if (b.description.contains('Taxi booking:')) {
        // Simple parsing logic
        final parts = b.description.split(':');
        if (parts.length > 1) {
          final content = parts[1].trim();
          final viaParts = content.split(' via ');
          if (viaParts.length > 1) {
            final routeParts = viaParts[0].split(' to ');
            if (routeParts.length > 1) {
              pickup = routeParts[0].trim();
              dropoff = routeParts[1].trim();
            }
            final vehicleParts = viaParts[1].split(' (');
            if (vehicleParts.length > 1) {
              vehicle = vehicleParts[0].trim();
              distance = vehicleParts[1].replaceFirst(' km)', '').trim();
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error parsing description: ${b.description}");
    }

    return BookingRequest(
      id: b.id ?? 0,
      customerName: b.customerName,
      customerPhone: "Not available",
      pickupLocation: pickup,
      dropoffLocation: dropoff,
      distance: distance,
      estimatedDuration: "N/A",
      fare: "₹${b.price}",
      packageType: vehicle, // Using vehicle type here
      packageWeight: "N/A",
      requestTime: b.requestDate,
      isUrgent: false,
    );
  }

  Future<void> _handleAcceptRequest(int requestId) async {
    try {
      final currentUser = AuthService().currentUser;
      final workType = currentUser?.workType ?? 'taxi';
      final workerName = currentUser?.name ?? 'Unknown Taxi Driver';

      await _databaseService.updateBookingStatus(
        requestId,
        'Accepted',
        role: workType,
        workerName: workerName,
      );
      _loadRequests(); // Refresh list

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request accepted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint("Error accepting taxi request: $e");
    }
  }

  Future<void> _handleRejectRequest(int requestId) async {
    try {
      final workType = AuthService().currentUser?.workType ?? 'taxi';
      await _databaseService.updateBookingStatus(
        requestId,
        'Rejected',
        role: workType,
      );
      _loadRequests(); // Refresh list

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request rejected'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      debugPrint("Error rejecting taxi request: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'GoodsTaxi Owner',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.orange[600],
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Pending"),
              Tab(text: "Accepted"),
              Tab(text: "Rejected"),
            ],
          ),
        ),

        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildRequestsList(requests),
                  _buildRequestsList(acceptedRequests, showButtons: false),
                  _buildRequestsList(rejectedRequests, showButtons: false),
                ],
              ),
      ),
    );
  }

  Widget _buildRequestsList(
    List<BookingRequest> list, {
    bool showButtons = true,
  }) {
    if (list.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _buildRequestCard(list[index], showButtons: showButtons);
      },
    );
  }

  Widget _buildRequestCard(BookingRequest request, {bool showButtons = true}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.customerName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      request.customerPhone,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildRouteItem(
                    Icons.radio_button_checked,
                    "Pickup",
                    request.pickupLocation,
                    Colors.green,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 2,
                    height: 20,
                    color: Colors.grey[400],
                    margin: const EdgeInsets.only(left: 10),
                  ),
                  const SizedBox(height: 8),
                  _buildRouteItem(
                    Icons.location_on,
                    "Drop-off",
                    request.dropoffLocation,
                    Colors.red,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.directions_car,
                      size: 18,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      request.packageType,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Text(
                  "Distance: ${request.distance} km",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                Text(
                  request.fare,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (showButtons)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleRejectRequest(request.id),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleAcceptRequest(request.id),
                      icon: const Icon(Icons.check),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 8),
            Text(
              "Received ${request.requestTime}",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteItem(
    IconData icon,
    String label,
    String location,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(location)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "No Requests Available",
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}

class BookingRequest {
  final int id;
  final String customerName;
  final String customerPhone;
  final String pickupLocation;
  final String dropoffLocation;
  final String distance;
  final String estimatedDuration;
  final String fare;
  final String packageType;
  final String packageWeight;
  final String requestTime;
  final bool isUrgent;

  BookingRequest({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.distance,
    required this.estimatedDuration,
    required this.fare,
    required this.packageType,
    required this.packageWeight,
    required this.requestTime,
    required this.isUrgent,
  });
}



// import 'package:flutter/material.dart';

// class GoodsTaxiOwnerHomePage extends StatefulWidget {
//   const GoodsTaxiOwnerHomePage({Key? key}) : super(key: key);

//   @override
//   State<GoodsTaxiOwnerHomePage> createState() => _GoodsTaxiOwnerHomePageState();
// }

// class _GoodsTaxiOwnerHomePageState extends State<GoodsTaxiOwnerHomePage> {
//   List<BookingRequest> requests = [
//     BookingRequest(
//       id: 1,
//       customerName: "John Smith",
//       customerPhone: "+1-555-0123",
//       pickupLocation: "123 Main St, Downtown",
//       dropoffLocation: "456 Oak Ave, Uptown",
//       distance: "12.5 km",
//       estimatedDuration: "25 min",
//       fare: "\$45.50",
//       packageType: "Electronics",
//       packageWeight: "5 kg",
//       requestTime: "2 minutes ago",
//       isUrgent: false,
//     ),
//     BookingRequest(
//       id: 2,
//       customerName: "Sarah Johnson",
//       customerPhone: "+1-555-0456",
//       pickupLocation: "789 Pine St, Westside",
//       dropoffLocation: "321 Elm St, Eastside",
//       distance: "8.2 km",
//       estimatedDuration: "18 min",
//       fare: "\$32.00",
//       packageType: "Documents",
//       packageWeight: "1 kg",
//       requestTime: "5 minutes ago",
//       isUrgent: true,
//     ),
//     BookingRequest(
//       id: 3,
//       customerName: "Mike Wilson",
//       customerPhone: "+1-555-0789",
//       pickupLocation: "555 Market St, Central",
//       dropoffLocation: "777 Broadway, North",
//       distance: "15.8 km",
//       estimatedDuration: "35 min",
//       fare: "\$58.75",
//       packageType: "Furniture",
//       packageWeight: "25 kg",
//       requestTime: "8 minutes ago",
//       isUrgent: false,
//     ),
//   ];

//   int acceptedCount = 12;
//   int rejectedCount = 3;
//   double todayEarnings = 245.80;

//   void _handleAcceptRequest(int requestId) {
//     setState(() {
//       requests.removeWhere((request) => request.id == requestId);
//       acceptedCount++;
//       // In a real app, you would send this to your backend
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Request accepted successfully!'),
//         backgroundColor: Colors.green,
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   void _handleRejectRequest(int requestId) {
//     setState(() {
//       requests.removeWhere((request) => request.id == requestId);
//       rejectedCount++;
//       // In a real app, you would send this to your backend
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Request rejected'),
//         backgroundColor: Colors.orange,
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text(
//           'GoodsTaxi Owner',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: Colors.orange[600],
//         elevation: 0,
//         actions: [
//           Stack(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.notifications, color: Colors.white),
//                 onPressed: () {},
//               ),
//               if (requests.isNotEmpty)
//                 Positioned(
//                   right: 8,
//                   top: 8,
//                   child: Container(
//                     padding: const EdgeInsets.all(2),
//                     decoration: BoxDecoration(
//                       color: Colors.red,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     constraints: const BoxConstraints(
//                       minWidth: 16,
//                       minHeight: 16,
//                     ),
//                     child: Text(
//                       '${requests.length}',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Stats Container
//           Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.orange[600]!, Colors.orange[400]!],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     _buildStatCard(
//                       'Today\'s Earnings',
//                       '\$${todayEarnings.toStringAsFixed(2)}',
//                       Icons.attach_money,
//                       Colors.green,
//                     ),
//                     _buildStatCard(
//                       'Accepted',
//                       acceptedCount.toString(),
//                       Icons.check_circle,
//                       Colors.blue,
//                     ),
//                     _buildStatCard(
//                       'Pending',
//                       requests.length.toString(),
//                       Icons.pending,
//                       Colors.orange,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
          
//           // Requests Header
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 const Icon(Icons.local_shipping, color: Colors.grey),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Incoming Requests (${requests.length})',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Requests List
//           Expanded(
//             child: requests.isEmpty
//                 ? _buildEmptyState()
//                 : ListView.builder(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     itemCount: requests.length,
//                     itemBuilder: (context, index) {
//                       return _buildRequestCard(requests[index]);
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard(String title, String value, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: Colors.white, size: 24),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(
//             title,
//             style: const TextStyle(
//               color: Colors.white70,
//               fontSize: 12,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.inbox_outlined,
//             size: 64,
//             color: Colors.grey[400],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No pending requests',
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'New delivery requests will appear here',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[500],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRequestCard(BookingRequest request) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
         
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header with customer info and urgent badge
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Row(
//                       children: [
//                         const CircleAvatar(
//                           // backgroundColor: Colors.blue,
//                           child: Icon(Icons.person, color: Colors.white),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 request.customerName,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               Text(
//                                 request.customerPhone,
//                                 style: TextStyle(
//                                   color: Colors.grey[600],
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
                 
//                 ],
//               ),

//               const SizedBox(height: 16),

//               // Route Information
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   children: [
//                     _buildRouteItem(
//                       Icons.radio_button_checked,
//                       'Pickup',
//                       request.pickupLocation,
//                       Colors.green,
//                     ),
//                     const SizedBox(height: 8),
//                     Container(
//                       width: 2,
//                       height: 20,
//                       color: Colors.grey[400],
//                       margin: const EdgeInsets.only(left: 10),
//                     ),
//                     const SizedBox(height: 8),
//                     _buildRouteItem(
//                       Icons.location_on,
//                       'Drop-off',
//                       request.dropoffLocation,
//                       Colors.red,
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Trip Details
           

//               const SizedBox(height: 12),

//               // Package Details
            

//               const SizedBox(height: 16),

//               // Action Buttons
//               Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: () => _handleRejectRequest(request.id),
//                       icon: const Icon(Icons.close),
//                       label: const Text('Reject'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.grey[200],
//                         foregroundColor: Colors.grey[700],
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: () => _handleAcceptRequest(request.id),
//                       icon: const Icon(Icons.check),
//                       label: const Text('Accept'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               // Request Time
//               Padding(
//                 padding: const EdgeInsets.only(top: 8),
//                 child: Text(
//                   'Received ${request.requestTime}',
//                   style: TextStyle(
//                     color: Colors.grey[500],
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRouteItem(IconData icon, String label, String location, Color color) {
//     return Row(
//       children: [
//         Icon(icon, color: color, size: 20),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               Text(
//                 location,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }


// }

// class BookingRequest {
//   final int id;
//   final String customerName;
//   final String customerPhone;
//   final String pickupLocation;
//   final String dropoffLocation;
//   final String distance;
//   final String estimatedDuration;
//   final String fare;
//   final String packageType;
//   final String packageWeight;
//   final String requestTime;
//   final bool isUrgent;

//   BookingRequest({
//     required this.id,
//     required this.customerName,
//     required this.customerPhone,
//     required this.pickupLocation,
//     required this.dropoffLocation,
//     required this.distance,
//     required this.estimatedDuration,
//     required this.fare,
//     required this.packageType,
//     required this.packageWeight,
//     required this.requestTime,
//     required this.isUrgent,
//   });
// }

// // Usage in main.dart:
// /*
// import 'package:flutter/material.dart';
// import 'goodstaxi_owner_homepage.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'GoodsTaxi Owner',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const GoodsTaxiOwnerHomePage(),
//     );
//   }
// }
// */