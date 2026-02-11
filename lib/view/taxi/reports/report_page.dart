import 'package:flutter/material.dart';
import '../../../services/database_service.dart';
import '../../../services/auth_service.dart';
import '../../../model/user_request.dart';

class TaxiMonthlyReportPage extends StatefulWidget {
  const TaxiMonthlyReportPage({super.key});

  @override
  State<TaxiMonthlyReportPage> createState() => _TaxiMonthlyReportPageState();
}

class _TaxiMonthlyReportPageState extends State<TaxiMonthlyReportPage> {
  DateTime selectedMonth = DateTime.now();
  final DatabaseService _databaseService = DatabaseService();
  List<UserRequest> bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMonthlyBookings();
  }

  Future<void> _loadMonthlyBookings() async {
    setState(() => _isLoading = true);
    try {
      final workType = AuthService().currentUser?.workType ?? 'taxi';
      final allBookings = await _databaseService.getBookings(role: workType);

      setState(() {
        bookings = allBookings.where((b) {
          try {
            final date = DateTime.parse(b.requestDate);
            return date.month == selectedMonth.month &&
                date.year == selectedMonth.year &&
                (b.status.toLowerCase() == 'completed' ||
                    b.status.toLowerCase() == 'accepted');
          } catch (e) {
            return false;
          }
        }).toList();
      });
    } catch (e) {
      debugPrint("Error loading monthly taxi bookings: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalRevenue = bookings.fold(0.0, (sum, item) => sum + item.price);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          "Taxi Monthly Report",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month picker
            GestureDetector(
              onTap: _selectMonth,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${_monthName(selectedMonth.month)} ${selectedMonth.year}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.calendar_month, color: Colors.orange),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Summary Cards
            Row(
              children: [
                _summaryCard(
                  "Total Rides",
                  bookings.length.toString(),
                  Icons.local_taxi,
                ),
                const SizedBox(width: 10),
                _summaryCard(
                  "Total Revenue",
                  "₹$totalRevenue",
                  Icons.currency_rupee,
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              "Completed Rides",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 12),

            // Ride List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : bookings.isEmpty
                  ? const Center(child: Text("No rides for this month"))
                  : ListView.builder(
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final ride = bookings[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            title: Text(
                              ride.service,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(ride.requestDate),
                            trailing: Text(
                              "₹${ride.price}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
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

  // ---------- Month Picker ----------
  Future<void> _selectMonth() async {
    final result = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2023, 1),
      lastDate: DateTime.now(),
      helpText: "Select Month",
    );

    if (result != null) {
      setState(() => selectedMonth = result);
      _loadMonthlyBookings();
    }
  }

  // ---------- Month Name ----------
  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }

  // Summary Card
  Widget _summaryCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.orange, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
