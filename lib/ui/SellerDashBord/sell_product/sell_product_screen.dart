import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/product_controller.dart';
import '../../../approutes/app_routes.dart';
import '../../../utils/app_colors.dart';
import 'components/dashboard_header.dart';
import 'components/stat_card.dart';
import 'components/action_buttons.dart';
import 'components/section_header.dart';
import 'components/product_list.dart';

class SellDashboard extends StatefulWidget {
  const SellDashboard({super.key});

  @override
  State<SellDashboard> createState() => _SellDashboardState();
}

class _SellDashboardState extends State<SellDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductController>(context, listen: false).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppColors.backgroundDecoration,
        child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardHeader(),
            SizedBox(height: 24),
            Consumer<ProductController>(
              builder: (context, productController, child) {
                return Row(
                  children: [
                    StatCard(
                      title: 'Total Crops',
                      value: productController.getCropsCount().toString(),
                      icon: Icons.inventory,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 12),
                    StatCard(
                      title: 'Total Seeds',
                      value: productController.getSeedsCount().toString(),
                      icon: Icons.shopping_cart,
                      color: Colors.orange,
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 24),
            ActionButtons(),
            SizedBox(height: 24),
            SectionHeader(title: 'Crops', icon: Icons.agriculture),
            SizedBox(height: 8),
            ProductList(collection: 'crops'),
            SizedBox(height: 20),
            SectionHeader(title: 'Seeds', icon: Icons.grass),
            SizedBox(height: 8),
            ProductList(collection: 'seeds'),
            SizedBox(height: 20),
          ],
        ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AppRoutes.navigateTo(context, AppRoutes.addProduct),
        backgroundColor: Colors.green[700],
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}