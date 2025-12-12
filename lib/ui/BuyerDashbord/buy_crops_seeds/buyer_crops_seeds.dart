import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_utils.dart';
import '../../../controllers/buyer_controller.dart';
import '../Helper/search_bar.dart' as CustomSearchBar;
import 'components/custom_tab_bar.dart';
import 'components/product_card.dart';
import '../Helper/order_rent_screen.dart';

class BuyerCropsSeeds extends StatefulWidget {
  const BuyerCropsSeeds({super.key});

  @override
  State<BuyerCropsSeeds> createState() => _BuyerCropsSeedsState();
}

class _BuyerCropsSeedsState extends State<BuyerCropsSeeds> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppColors.backgroundDecoration,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.grey[50]!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                CustomSearchBar.SearchBar(
                  hintText: 'Search crops, seeds...',
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                ),
                CustomTabBar(controller: _tabController),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductList('crops'),
                _buildProductList('seeds'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(String collection) {
    final buyerController = Provider.of<BuyerController>(context, listen: false);
    
    return StreamBuilder<QuerySnapshot>(
      stream: collection == 'crops' 
          ? buyerController.getCropsStream() 
          : buyerController.getSeedsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No ${collection} available',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final filteredDocs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
          return name.contains(searchQuery);
        }).toList();

        if (filteredDocs.isEmpty) {
          return Center(
            child: Text(
              'No results found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final data = filteredDocs[index].data() as Map<String, dynamic>;
            final productId = filteredDocs[index].id;
            return Consumer<BuyerController>(
              builder: (context, buyerController, child) {
                data['id'] = productId; // Add ID to data
                return ProductCard(
                  data: data,
                  type: collection,
                  isFavorite: buyerController.isFavorite(data),
                  onOrder: () => _showOrderDialog(data, collection),
                  onFavorite: () {
                    buyerController.addToFavorites(data);
                    final isNowFavorite = buyerController.isFavorite(data);
                    AppUtils.showSnackBar(context, isNowFavorite ? 'Added to favorites' : 'Removed from favorites');
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _showOrderDialog(Map<String, dynamic> data, String collection) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderRentScreen(
          itemData: data,
          orderType: collection == 'crops' ? OrderType.crops : OrderType.seeds,
        ),
      ),
    );
  }
}
