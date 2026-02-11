import 'package:flutter/material.dart';
import '../../../services/database_service.dart';
import '../../../model/user_request.dart';

class UserBookingPage extends StatefulWidget {
  @override
  _UserBookingPageState createState() => _UserBookingPageState();
}

class _UserBookingPageState extends State<UserBookingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService();

  List<UserRequest> userRequests = [];
  List<UserRequest> taxiRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allBookings = await _databaseService.getBookings();

      // For demonstration, if database is empty, insert initial data
      if (allBookings.isEmpty) {
        await _insertInitialData();
        final refreshedBookings = await _databaseService.getBookings();
        _distributeBookings(refreshedBookings);
      } else {
        _distributeBookings(allBookings);
      }
    } catch (e) {
      debugPrint("Error loading bookings: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _distributeBookings(List<UserRequest> bookings) {
    setState(() {
      userRequests = bookings
          .where((r) => r.service != 'Taxi Booking')
          .toList();
      taxiRequests = bookings
          .where((r) => r.service == 'Taxi Booking')
          .toList();
    });
  }

  Future<void> _insertInitialData() async {
    final initialData = [
      UserRequest(
        service: 'Plumbing Repair',
        workerName: 'John Smith',
        customerName: 'Customer A',
        requestDate: '2024-01-15',
        status: 'accepted',
        price: 150,
        description: 'Fix kitchen sink leak',
      ),
      UserRequest(
        service: 'Electrical Work',
        workerName: 'Mike Johnson',
        customerName: 'Customer B',
        requestDate: '2024-01-14',
        status: 'rejected',
        price: 200,
        description: 'Install ceiling fan',
      ),
      UserRequest(
        service: 'Taxi Booking',
        workerName: 'Driver: Alex Kumar',
        customerName: 'Customer C',
        requestDate: '2024-01-20',
        status: 'accepted',
        price: 350,
        description: 'Trip to Airport - 25 km',
      ),
      UserRequest(
        service: 'Taxi Booking',
        workerName: 'Driver: Rahul Singh',
        customerName: 'Customer D',
        requestDate: '2024-01-18',
        status: 'pending',
        price: 220,
        description: 'City to Bus Stand',
      ),
    ];

    for (var booking in initialData) {
      await _databaseService.insertBooking(booking);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('My Requests', style: TextStyle(color: Colors.white)),
        ),
        backgroundColor: Colors.orange,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: [
            Tab(icon: Icon(Icons.miscellaneous_services), text: "Services"),
            Tab(icon: Icon(Icons.local_taxi), text: "Taxi"),
          ],
        ),
      ),

      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // SERVICE REQUEST TAB
                userRequests.isEmpty
                    ? Center(child: Text("No service requests found"))
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: userRequests.length,
                        itemBuilder: (context, index) {
                          return RequestCard(request: userRequests[index]);
                        },
                      ),

                // TAXI REQUEST TAB
                taxiRequests.isEmpty
                    ? Center(child: Text("No taxi requests found"))
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: taxiRequests.length,
                        itemBuilder: (context, index) {
                          return RequestCard(request: taxiRequests[index]);
                        },
                      ),
              ],
            ),
    );
  }
}

class RequestCard extends StatelessWidget {
  final UserRequest request;

  RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service & Status
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.service,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    request.status.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            Row(
              children: [
                CircleAvatar(
                  child: Text(request.workerName[0]),
                  backgroundColor: Colors.orange,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Worker: ${request.workerName}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Price: ₹${request.price}',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            Text(
              request.description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),

            SizedBox(height: 12),

            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Requested on: ${request.requestDate}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),

            if (request.status.toLowerCase() != 'pending') ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(request.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      request.status.toLowerCase() == 'accepted'
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: _getStatusColor(request.status),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.status.toLowerCase() == 'accepted'
                            ? 'Great! ${request.workerName} accepted your request'
                            : 'Sorry, ${request.workerName} declined your request',
                        style: TextStyle(
                          color: _getStatusColor(request.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (request.status == 'accepted') ...[
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: Text(
                    'Pay Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
