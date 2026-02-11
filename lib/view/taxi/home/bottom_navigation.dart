
import 'package:findmyservicesapp/view/taxi/home/home_screen.dart';
import 'package:findmyservicesapp/view/taxi/reports/report_page.dart';
import 'package:findmyservicesapp/view/taxi/review/worker_reviews.dart';
import 'package:findmyservicesapp/view/user/booking/bookings_screen.dart';
import 'package:findmyservicesapp/view/user/home/home_screen.dart';
import 'package:findmyservicesapp/view/user/profile/profile_screen.dart';

import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  // List of pages for navigation
  final List<Widget> _pages = [
    GoodsTaxiOwnerHomePage(),
    ReviewManagementPage(),
    TaxiMonthlyReportPage(),
    ProfilePage(),
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
              label: 'Reviews',
            ),
             BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
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
