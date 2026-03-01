import 'package:findmyservicesapp/services/auth_service.dart';
import 'package:findmyservicesapp/view/admin/adminhome.dart';
import 'package:findmyservicesapp/view/auth/login_screen.dart';
import 'package:findmyservicesapp/view/taxi/home/bottom_navigation.dart';
import 'package:findmyservicesapp/view/user/home/bottom_navigationbar.dart';
import 'package:findmyservicesapp/view/workers/booking/bottom_nav.dart';
import 'package:flutter/material.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final authService = AuthService();
    await authService.loadSession();

    // Small delay to show logo
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (authService.isLoggedIn) {
      final user = authService.currentUser!;
      final role = user.role;

      Widget homeScreen;
      if (user.email == "admin@gmail.com") {
        homeScreen = const AdminApprovalScreen();
      } else if (role == "Customer") {
        homeScreen = BottomNav();
      } else if (role == "Worker") {
        homeScreen = BottomNavigation();
      } else if (role == "Goods Taxi") {
        homeScreen = BottomNavBar();
      } else {
        homeScreen = LoginScreen();
      }

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => homeScreen));
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/logo.png', height: 300, width: 300),
      ),
    );
  }
}
