import 'dart:async';
import 'package:flutter/material.dart';
import '../../approutes/app_routes.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    await Future.delayed(Duration(seconds: 3));
    
    bool isLoggedIn = await AuthService.isLoggedIn();
    
    if (isLoggedIn) {
      String? role = await AuthService.getUserRole();
      
      if (role == 'Seller') {
        AppRoutes.navigateAndClearStack(context, AppRoutes.sellerDashboard);
      } else if (role == 'Buyer') {
        AppRoutes.navigateAndClearStack(context, AppRoutes.buyerRentMachinery);
      } else if (role == 'Labourer') {
        AppRoutes.navigateAndClearStack(context, AppRoutes.findLabour);
      } else {
        AppRoutes.navigateAndReplace(context, AppRoutes.login);
      }
    } else {
      AppRoutes.navigateAndReplace(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F9F1),
      body: Center(
        child: Container(
          height: 180,
          width: 180,
          child: Image.asset('assets/images/logo.png')
        ),
      ),
    );
  }
}