import 'package:findmyservicesapp/view/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:findmyservicesapp/services/auth_service.dart';
import '../../../services/database_service.dart';

class BookingPage extends StatefulWidget {
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage>
    with TickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  List<BookingRequest> bookingRequests = [];
  bool _isLoading = false;

  String selectedFilter = 'All';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final workType = AuthService().currentUser?.workType;
      final allBookings = await _databaseService.getBookings(role: workType);

      setState(() {
        bookingRequests = allBookings
            .map(
              (b) => BookingRequest(
                id: b.id.toString(),
                customerName:
                    b.customerName, // Fetching the actual requester's name
                customerImage: '',
                service: b.service,
                location:
                    'User Address', // Address could be added to UserRequest or UserModel
                scheduledTime:
                    DateTime.tryParse(b.requestDate) ?? DateTime.now(),
                price: b.price.toDouble(),
                description: b.description,
                status: _mapStatusToEnum(b.status),
                customerRating: 4.5,
                distance: 'Local',
                urgency: 'Standard',
              ),
            )
            .toList();
      });
    } catch (e) {
      debugPrint("Error loading bookings: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  BookingStatus _mapStatusToEnum(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return BookingStatus.accepted;
      case 'rejected':
      case 'completed':
        return BookingStatus.rejected;
      default:
        return BookingStatus.pending;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade400,
        elevation: 0,
        title: Text(
          'Service Bookings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.orange.shade400,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.orange.shade600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Colors.grey, size: 40),
                    ),
                    SizedBox(height: 10),

                    Text(
                      AuthService().currentUser?.email ?? 'worker@gmail.com',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.home, color: Colors.orange),
                title: Text(
                  'Home',
                  style: TextStyle(color: Colors.orange, fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                },
              ),
              ListTile(
                leading: Icon(Icons.person, color: Colors.orange),
                title: Text(
                  'Profile',
                  style: TextStyle(color: Colors.orange, fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.settings, color: Colors.orange),
                title: Text(
                  'Settings',
                  style: TextStyle(color: Colors.orange, fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              Divider(color: Colors.grey.shade200),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.orange),
                title: Text(
                  'Logout',
                  style: TextStyle(color: Colors.orange, fontSize: 16),
                ),
                onTap: () {
                  _handleLogout();
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade400, Colors.orange.shade200],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.white))
              : Column(
                  children: [
                    // Tab Bar
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TabBar(
                        indicatorColor: Colors.transparent,
                        dividerColor: Colors.transparent,
                        controller: _tabController,
                        labelColor: Colors.orange,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.orange,
                        ),
                        tabs: [
                          Tab(text: 'Pending (${_getPendingCount()})'),
                          Tab(text: 'Accepted (${_getAcceptedCount()})'),
                          Tab(text: 'Rejected (${_getRejectedCount()})'),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    // Booking List
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(25),
                          ),
                        ),
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildBookingList(
                              _getFilteredRequests(BookingStatus.pending),
                            ),
                            _buildBookingList(
                              _getFilteredRequests(BookingStatus.accepted),
                            ),
                            _buildBookingList(
                              _getFilteredRequests(BookingStatus.rejected),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildBookingList(List<BookingRequest> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade400),
            SizedBox(height: 20),
            Text(
              'No booking requests',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'New requests will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        return _buildBookingCard(requests[index]);
      },
    );
  }

  Widget _buildBookingCard(BookingRequest booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: _getStatusColor(booking.status).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with customer info and urgency
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.orange.shade100,
                  child: Text(
                    booking.customerName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            booking.customerName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getUrgencyColor(booking.urgency),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              booking.urgency,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 5),
                          Text(
                            '${booking.customerRating}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 15),
                          Icon(Icons.location_on, color: Colors.grey, size: 16),
                          SizedBox(width: 5),
                          Text(
                            booking.distance,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    booking.status.toString().split('.').last.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(booking.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 15),

            // Service info
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getServiceIcon(booking.service),
                        color: Colors.orange,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        booking.service,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      Spacer(),
                      Text(
                        '\$${booking.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    booking.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),

            SizedBox(height: 15),

            // Location and time
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          booking.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey, size: 18),
                SizedBox(width: 8),
                Text(
                  '${_formatDateTime(booking.scheduledTime)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            if (booking.status == BookingStatus.pending) ...[
              SizedBox(height: 20),
              // Action buttons for pending requests
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _rejectBooking(booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Decline',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _acceptBooking(booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade400,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Accept',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (booking.status == BookingStatus.accepted) ...[
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _viewBookingDetails(booking),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.visibility, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'View Details',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.accepted:
        return Colors.green;
      case BookingStatus.rejected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getServiceIcon(String service) {
    if (service.toLowerCase().contains('plumb')) return Icons.plumbing;
    if (service.toLowerCase().contains('electric'))
      return Icons.electrical_services;
    if (service.toLowerCase().contains('clean')) return Icons.cleaning_services;
    if (service.toLowerCase().contains('transport') ||
        service.toLowerCase().contains('goods'))
      return Icons.local_shipping;
    return Icons.handyman;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} from now';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} from now';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} from now';
    } else {
      return 'Completed';
    }
  }

  int _getPendingCount() {
    return bookingRequests
        .where((r) => r.status == BookingStatus.pending)
        .length;
  }

  int _getAcceptedCount() {
    return bookingRequests
        .where((r) => r.status == BookingStatus.accepted)
        .length;
  }

  int _getRejectedCount() {
    return bookingRequests
        .where((r) => r.status == BookingStatus.rejected)
        .length;
  }

  List<BookingRequest> _getFilteredRequests(BookingStatus status) {
    return bookingRequests.where((r) => r.status == status).toList();
  }

  Future<void> _acceptBooking(BookingRequest booking) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Accept"),
        content: Text("Do you want to accept this booking?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
            },
            child: Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              try {
                final currentUser = AuthService().currentUser;
                final workType = currentUser?.workType;
                final workerName = currentUser?.name;

                await _databaseService.updateBookingStatus(
                  int.parse(booking.id),
                  'Accepted',
                  role: workType,
                  workerName: workerName,
                );
                setState(() {
                  booking.status = BookingStatus.accepted;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Booking accepted successfully!'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                debugPrint("Error accepting booking: $e");
              }
            },
            child: Text("Accept", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Future<void> _rejectBooking(BookingRequest booking) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Decline Booking'),
          content: Text(
            'Are you sure you want to decline this booking request?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  final workType = AuthService().currentUser?.workType;
                  await _databaseService.updateBookingStatus(
                    int.parse(booking.id),
                    'Rejected',
                    role: workType,
                  );
                  setState(() {
                    booking.status = BookingStatus.rejected;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Booking declined'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  debugPrint("Error rejecting booking: $e");
                }
              },
              child: Text('Decline', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _viewBookingDetails(BookingRequest booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening booking details for ${booking.customerName}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logged out successfully'),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

enum BookingStatus { pending, accepted, rejected }

class BookingRequest {
  final String id;
  final String customerName;
  final String customerImage;
  final String service;
  final String location;
  final DateTime scheduledTime;
  final double price;
  final String description;
  BookingStatus status;
  final double customerRating;
  final String distance;
  final String urgency;

  BookingRequest({
    required this.id,
    required this.customerName,
    required this.customerImage,
    required this.service,
    required this.location,
    required this.scheduledTime,
    required this.price,
    required this.description,
    required this.status,
    required this.customerRating,
    required this.distance,
    required this.urgency,
  });
}
