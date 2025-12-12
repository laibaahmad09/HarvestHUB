import 'package:first_project/approutes/app_routes.dart';
import 'rent_machinery/buyer_rent_machinery.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../controllers/user_controller.dart';
import '../../controllers/buyer_controller.dart';
import '../../approutes/app_routes.dart';
import 'buy_crops_seeds/buyer_crops_seeds.dart';
import 'buyer_favorites/buyer_favorites.dart';
import 'buyer_orders/buyer_orders.dart';
import '../SellerDashBord/Helper/custom_drawer.dart';

class BuyerDashboard extends StatefulWidget {
  const BuyerDashboard({super.key});

  @override
  State<BuyerDashboard> createState() => _BuyerDashboardState();
}

class _BuyerDashboardState extends State<BuyerDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const BuyerCropsSeeds(),
    const BuyerRentMachinery(),
    const BuyerFavorites(),
    const BuyerOrders(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserController>(context, listen: false).loadUserData();
      // Load saved favorites from device storage
      Provider.of<BuyerController>(context, listen: false).loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getTitle(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E5E25),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Container(
              width: 24,
              height: 24,
              child: Stack(
                children: [
                  Positioned(
                    top: 4,
                    left: 0,
                    child: Container(
                      width: 16,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 11,
                    left: 4,
                    child: Container(
                      width: 20,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 18,
                    left: 2,
                    child: Container(
                      width: 18,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Consumer<UserController>(
            builder: (context, userController, child) {
              return GestureDetector(
                onTap: () {
                  AppRoutes.navigateTo(context, AppRoutes.profile);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8, top: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: Colors.white,
                    child: _buildProfileImage(userController),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E5E25),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            label: 'Buy Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.agriculture),
            label: 'Rent Machinery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'My Orders',
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Buy Crops & Seeds';
      case 1:
        return 'Rent Machinery';
      case 2:
        return 'Favorites';
      case 3:
        return 'My Orders';
      default:
        return 'Buyer Dashboard';
    }
  }

  Widget _buildProfileImage(UserController userController) {
    final profileImageBase64 = userController.userData?['profileImageBase64'] ?? '';
    
    if (profileImageBase64.isNotEmpty) {
      try {
        return ClipOval(
          child: Image.memory(
            base64Decode(profileImageBase64),
            width: 35,
            height: 35,
            fit: BoxFit.cover,
          ),
        );
      } catch (e) {
        print('Error decoding profile image: $e');
      }
    }
    
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(
        Icons.person,
        size: 20,
        color: Colors.white,
      ),
    );
  }
}
