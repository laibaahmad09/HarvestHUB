import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../controllers/buyer_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_utils.dart';
import '../Helper/search_bar.dart' as CustomSearchBar;
import 'components/category_filter.dart';
import 'components/machinery_card.dart';
import 'components/empty_state.dart';
import '../Helper/order_rent_screen.dart';

class BuyerRentMachinery extends StatefulWidget {
  const BuyerRentMachinery({super.key});

  @override
  State<BuyerRentMachinery> createState() => _BuyerRentMachineryState();
}

class _BuyerRentMachineryState extends State<BuyerRentMachinery> {
  String selectedCategory = 'All';
  String searchQuery = '';

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
                  hintText: 'Search machinery...',
                  onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: CategoryFilter(
                    selectedCategory: selectedCategory,
                    onCategorySelected: (category) => setState(() => selectedCategory = category),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: Provider.of<BuyerController>(context, listen: false).getMachineryStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const EmptyState(message: 'No machinery available');
                }

                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final category = data['category'] ?? '';
                  
                  bool matchesSearch = name.contains(searchQuery);
                  bool matchesCategory = selectedCategory == 'All' || category == selectedCategory;
                  
                  return matchesSearch && matchesCategory;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const EmptyState(message: 'No results found');
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final data = filteredDocs[index].data() as Map<String, dynamic>;
                    data['id'] = filteredDocs[index].id; // Add ID to data
                    return Consumer<BuyerController>(
                      builder: (context, controller, child) {
                        return MachineryCard(
                          machinery: data,
                          isFavorite: controller.isFavorite(data),
                          onFavorite: () => _handleFavorite(data, controller),
                          onRent: () => _handleRent(data),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleFavorite(Map<String, dynamic> machinery, BuyerController controller) {
    controller.addToFavorites(machinery);
    final isNowFavorite = controller.isFavorite(machinery);
    AppUtils.showSnackBar(context, isNowFavorite ? 'Added to favorites' : 'Removed from favorites');
  }

  void _handleRent(Map<String, dynamic> machinery) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderRentScreen(
          itemData: machinery,
          orderType: OrderType.machinery,
        ),
      ),
    );
  }
}