import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/database_service.dart';
import '../../../model/user_request.dart';
import '../../../services/auth_service.dart';

class MonthlyReportPage extends StatefulWidget {
  const MonthlyReportPage({super.key});

  @override
  State<MonthlyReportPage> createState() => _MonthlyReportPageState();
}

class _MonthlyReportPageState extends State<MonthlyReportPage> {
  String selectedMonth = DateFormat(
    'MMMM yyyy',
  ).format(DateTime.now()); // default current month

  final DatabaseService _databaseService = DatabaseService();
  List<UserRequest> monthlyBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMonthlyBookings();
  }

  Future<void> _loadMonthlyBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final workType = AuthService().currentUser?.workType;
      final allBookings = await _databaseService.getBookings(role: workType);

      setState(() {
        // Filter bookings by selected month and year
        // We look for the month name in the requestDate string
        monthlyBookings = allBookings.where((b) {
          final date =
              b.requestDate; // Format: "yyyy-MM-dd HH:mm:ss" or similar
          try {
            final dt = DateTime.parse(date);
            final bookingMonthStr = DateFormat('MMMM yyyy').format(dt);
            return bookingMonthStr == selectedMonth &&
                b.status.toLowerCase() == 'accepted';
          } catch (e) {
            // Fallback for different date formats if necessary
            return false;
          }
        }).toList();
      });
    } catch (e) {
      debugPrint("Error loading monthly report: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickMonth() async {
    final DateTime now = DateTime.now();
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      helpText: "Select Month",
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: Colors.orange),
          ),
          child: child!,
        );
      },
    );

    if (newDate != null) {
      setState(() {
        selectedMonth = DateFormat('MMMM yyyy').format(newDate);
      });
      _loadMonthlyBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = monthlyBookings.fold(
      0.0,
      (sum, item) => sum + item.price,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Monthly Report", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),

      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // MONTH PICKER SECTION
                  GestureDetector(
                    onTap: _pickMonth,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedMonth,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(Icons.calendar_month, color: Colors.orange),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // SUMMARY CARDS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryCard(
                        "Total Bookings",
                        monthlyBookings.length.toString(),
                        Icons.list,
                      ),
                      _buildSummaryCard(
                        "Total Revenue",
                        "₹${totalAmount.toInt()}",
                        Icons.currency_rupee,
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Text(
                    "Completed Bookings",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  Expanded(
                    child: monthlyBookings.isEmpty
                        ? Center(
                            child: Text("No bookings found for this month"),
                          )
                        : ListView.builder(
                            itemCount: monthlyBookings.length,
                            itemBuilder: (context, index) {
                              final booking = monthlyBookings[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                child: ListTile(
                                  leading: Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                  title: Text(booking.service),
                                  subtitle: Text(
                                    "${booking.workerName} • ${booking.requestDate}",
                                  ),
                                  trailing: Text(
                                    "₹${booking.price}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.orange),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
