import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/buyer_controller.dart';
import '../../../../utils/app_utils.dart';
import '../../buy_crops_seeds/components/product_card.dart';
import '../../rent_machinery/components/machinery_card.dart';
import '../../Helper/order_rent_screen.dart';

class FavoriteItem extends StatelessWidget {
  final Map<String, dynamic> product;

  const FavoriteItem({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final buyerController = Provider.of<BuyerController>(context, listen: false);
    
    // Check if it's machinery or crop/seed
    if (product.containsKey('pricePerDay')) {
      // It's machinery
      return MachineryCard(
        machinery: product,
        isFavorite: true,
        onFavorite: () => _handleFavorite(context, buyerController),
        onRent: () => _handleRent(context),
      );
    } else {
      // It's crop or seed
      final productType = product.containsKey('variety') ? 'seeds' : 'crops';
      return ProductCard(
        data: product,
        type: productType,
        isFavorite: true,
        onOrder: () => _showOrderDialog(context),
        onFavorite: () => _handleFavorite(context, buyerController),
      );
    }
  }

  void _handleFavorite(BuildContext context, BuyerController controller) {
    controller.addToFavorites(product);
    AppUtils.showSnackBar(context, 'Removed from favorites');
  }

  void _showOrderDialog(BuildContext context) {
    final productType = product.containsKey('variety') ? 'seeds' : 'crops';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderRentScreen(
          itemData: product,
          orderType: productType == 'crops' ? OrderType.crops : OrderType.seeds,
        ),
      ),
    );
  }

  void _handleRent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderRentScreen(
          itemData: product,
          orderType: OrderType.machinery,
        ),
      ),
    );
  }
}