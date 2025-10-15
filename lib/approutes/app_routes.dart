import 'package:flutter/material.dart';
import '../ui/splashScreen/splash_screen.dart';
import '../ui/auth/login_page.dart';
import '../ui/auth/signup_Page.dart';
import '../ui/SelerDashBord/seller_dash_bord.dart';
import '../ui/SelerDashBord/profile_screen.dart';
import '../ui/SelerDashBord/inventory.dart';
import '../ui/SelerDashBord/find_labour.dart';
import '../ui/SelerDashBord/rent_machinery.dart';
import '../ui/SelerDashBord/SellProductScreen/sell_product.dart';
import '../ui/SelerDashBord/SellProductScreen/add_product.dart';
import '../ui/SelerDashBord/BuyerDashbord/buyer_rent_machinery.dart';
import '../ui/SelerDashBord/BuyerDashbord/add_machinory.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String sellerDashboard = '/seller-dashboard';
  static const String profile = '/profile';
  static const String inventory = '/inventory';
  static const String findLabour = '/find-labour';
  static const String rentMachinery = '/rent-machinery';
  static const String sellProduct = '/sell-product';
  static const String buyerRentMachinery = '/buyer-rent-machinery';
  static const String addProduct = '/add-product';
  static const String addMachinery = '/add-machinery';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => SplashScreen(),
    login: (context) => LoginPage(),
    signup: (context) => SignupPage(),
    sellerDashboard: (context) => SellerDashboard(),
    profile: (context) => ProfileScreen(),
    inventory: (context) => InventoryDashboard(),
    findLabour: (context) => HireLabourDashboard(),
    rentMachinery: (context) => RentDashboard(),
    sellProduct: (context) => SellDashboard(),
    buyerRentMachinery: (context) => BuyerRentDashboard(),
    addProduct: (context) => AddProduct(),
    addMachinery: (context) => AddMachinery(),
  };

  static void navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  static void navigateAndReplace(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  static void navigateAndClearStack(BuildContext context, String routeName) {
    Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}