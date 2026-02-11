
import 'package:findmyservicesapp/view/user/booking/bookings_screen.dart';
import 'package:findmyservicesapp/view/user/home/home_screen.dart';
import 'package:findmyservicesapp/view/user/profile/profile_screen.dart';
import 'package:findmyservicesapp/view/workers/booking/booking_page.dart';
import 'package:findmyservicesapp/view/workers/profile/profile_page.dart';
import 'package:findmyservicesapp/view/workers/reports/report_page.dart';
import 'package:findmyservicesapp/view/workers/review/review_page.dart';

import 'package:flutter/material.dart';

class BottomNavigation extends StatefulWidget {
  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;

  // List of pages for navigation
  final List<Widget> _pages = [
    BookingPage(),
    ReviewsPage(),
    MonthlyReportPage(),
     WorkerProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 10,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_online),
              label: 'Review',
            ),
             BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
