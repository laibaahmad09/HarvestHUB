import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../controllers/buyer_controller.dart';
import 'components/empty_favorites_state.dart';
import 'components/favorite_item.dart';

class BuyerFavorites extends StatelessWidget {
  const BuyerFavorites({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppColors.backgroundDecoration,
      child: Consumer<BuyerController>(
        builder: (context, buyerController, child) {
          final favoriteProducts = buyerController.getFavoriteProducts();
          
          if (favoriteProducts.isEmpty) {
            return const EmptyFavoritesState();
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoriteProducts.length,
            itemBuilder: (context, index) {
              final product = favoriteProducts[index];
              return FavoriteItem(product: product);
            },
          );
        },
      ),
    );
  }
}