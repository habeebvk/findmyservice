
import 'package:findmyservicesapp/view/admin/adminhome.dart';
import 'package:findmyservicesapp/view/auth/login_screen.dart';
import 'package:flutter/material.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {

void initState() {
    super.initState();
    // Navigate to HomePage after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body:
      Center(child:Image.asset('assets/images/logo.png',height: 300,width: 300,)),
     
     );
  }
}