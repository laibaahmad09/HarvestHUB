import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../approutes/app_routes.dart';
import '../../../controllers/machinery_controller.dart';
import '../../../utils/app_colors.dart';
import 'components/machinery_header.dart';
import 'components/category_filter.dart';
import 'components/machinery_list.dart';
import 'components/stats_overlay.dart';

class RentDashboard extends StatefulWidget {
  const RentDashboard({super.key});

  @override
  State<RentDashboard> createState() => _RentDashboardState();
}

class _RentDashboardState extends State<RentDashboard>
    with TickerProviderStateMixin {
  String selectedCategory = 'All';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> categories = [
    'All',
    'Tractor',
    'Harvester',
    'Plough',
    'Cultivator',
    'Thresher',
    'Sprayer',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MachineryController>(context, listen: false).loadMachinery();
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppColors.backgroundDecoration,
        child: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                MachineryHeader(),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const SizedBox(height: 13),
                        CategoryFilter(
                          selectedCategory: selectedCategory,
                          categories: categories,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedCategory = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: MachineryList()),
              ],
            ),
          ),
          StatsOverlay(),
        ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AppRoutes.navigateTo(context, AppRoutes.addMachinery);
        },
        backgroundColor: const Color(0xFF43A047),
        elevation: 8,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Machinery',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
