import 'package:first_project/ui/SellerDashBord/Helper/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/labour_controller.dart';
import '../../approutes/app_routes.dart';
import '../../utils/profile_utils.dart';
import '../common/dashboard_header.dart';
import 'components/labour_registration_form.dart';
import 'components/labour_profile_card.dart';
import 'components/labour_stats_cards.dart';
import 'components/hire_requests_screen.dart';
import 'components/work_history_screen.dart';

class LabourDashboard extends StatefulWidget {
  const LabourDashboard({super.key});

  @override
  State<LabourDashboard> createState() => _LabourDashboardState();
}

class _LabourDashboardState extends State<LabourDashboard> {
  int _currentIndex = 0;
  bool _isInitialized = false;

  List<Widget> get _screens => [
    Consumer<LabourController>(
      builder: (context, labourController, child) {
        if (!_isInitialized || labourController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return labourController.hasProfile 
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DashboardHeader(
                      icon: Icons.work,
                      title: 'Labour Dashboard',
                      subtitle: 'Manage your work profile and requests',
                    ),
                    const SizedBox(height: 16),
                    const LabourStatsCards(),
                    const SizedBox(height: 16),
                    const LabourProfileCard(),
                  ],
                ),
              )
            : const LabourRegistrationForm();
      },
    ),
    const HireRequestsScreen(),
    const WorkHistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final userController = Provider.of<UserController>(context, listen: false);
    final labourController = Provider.of<LabourController>(context, listen: false);
    
    await Future.wait([
      userController.loadUserData(),
      labourController.loadLabourProfile(),
      labourController.loadHireRequests(),
    ]);
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LabourController>(
          builder: (context, labourController, child) {
            String title;
            if (_currentIndex == 0 && !labourController.hasProfile) {
              title = 'Registration';
            } else {
              switch (_currentIndex) {
                case 0:
                  title = 'Profile';
                case 1:
                  title = 'Hire Requests';
                case 2:
                  title = 'Work History';
                default:
                  title = 'Labour Dashboard';
              }
            }
            return Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            );
          },
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
                    child: ProfileUtils.buildProfileImage(userController.userData),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF1F9F1), Colors.white],
          ),
        ),
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
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Consumer<LabourController>(
          builder: (context, labourController, child) {
            final List<String> _titles = [
              labourController.hasProfile ? 'Profile' : 'Registration',
              'Hire Requests',
              'Work History',
            ];
            final List<IconData> _icons = [
              labourController.hasProfile ? Icons.person : Icons.person_add,
              Icons.work,
              Icons.history,
            ];
            final Color _selectedColor = const Color(0xFF2E5E25);
            
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_titles.length, (index) {
                    final isSelected = _currentIndex == index;
                    final color = isSelected ? _selectedColor : Colors.grey[600];
                    return GestureDetector(
                      onTap: () {
                        setState(() => _currentIndex = index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            const SizedBox(height: 4),
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
            );
          },
        ),
      ),
    );
  }


}