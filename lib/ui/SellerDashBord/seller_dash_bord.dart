import 'package:first_project/approutes/app_routes.dart';
import 'package:first_project/ui/SellerDashBord/hire_labour/hire_labour_screen.dart';
import 'package:first_project/ui/SellerDashBord/inventory/inventory_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'rent_machinery/rent_machinery_screen.dart';
import 'sell_product/sell_product_screen.dart';
import 'Helper/custom_drawer.dart';
import '../../controllers/user_controller.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _screens = [
    const SellDashboard(),
    const RentDashboard(),
    const HireLabourDashboard(),
    const InventoryDashboard(),
  ];
  final List<String> _titles = [
    'Sell Products',
    'Rent Machinery',
    'Hire Labour',
    'Inventory Management',
  ];
  final List<IconData> _icons = [
    Icons.store,
    Icons.precision_manufacturing,
    Icons.people_alt_outlined,
    Icons.inventory_2,
  ];
  final Color _selectedColor = Color(0xFF2E7D32);
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserController>(context, listen: false).loadUserData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text(
          "Seller Dashboard",
          style: TextStyle(color: Colors.white),
        ),
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
                  margin: EdgeInsets.only(right: 8, top: 8),
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
                        offset: Offset(0, 2),
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
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_titles.length, (index) {
                final isSelected = _currentIndex == index;
                final color = isSelected ? _selectedColor : Colors.grey[600];
                return GestureDetector(
                  onTap: () {
                    setState(() => _currentIndex = index);
                    _animationController.reset();
                    _animationController.forward();
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _selectedColor.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _icons[index],
                          color: color,
                          size: isSelected ? 28 : 24,
                        ),
                        SizedBox(height: 4),
                        Text(
                          _titles[index].split(' ')[0],
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
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
      child: Icon(
        Icons.person,
        size: 20,
        color: Colors.white,
      ),
    );
  }
}
