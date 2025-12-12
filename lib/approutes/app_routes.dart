import 'package:first_project/ui/SellerDashBord/inventory/inventory_screen.dart';
import 'package:first_project/ui/SellerDashBord/profile_screen.dart';
import 'package:first_project/ui/SellerDashBord/seller_dash_bord.dart';
import 'package:flutter/material.dart';
import '../ui/splashScreen/splash_screen.dart';
import '../ui/auth/login_page.dart';
import '../ui/auth/signup_Page.dart';
import '../ui/SellerDashBord/hire_labour/hire_labour_screen.dart';
import '../ui/SellerDashBord/rent_machinery/rent_machinery_screen.dart';
import '../ui/SellerDashBord/sell_product/sell_product_screen.dart';
import '../ui/SellerDashBord/add_products/add_product.dart';
import '../ui/BuyerDashbord/buyer_dashboard.dart';
import '../ui/SellerDashBord/add_products/add_machinory.dart';

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
  static const String buyerDashboard = '/buyer-dashboard';
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
        buyerDashboard: (context) => BuyerDashboard(),
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
