import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    final productId = product['id'];
    
    if (productId == null) {
      return Container();
    }
    
    // Check if it's machinery or crop/seed
    if (product.containsKey('pricePerDay')) {
      // It's machinery - fetch real-time data
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('machinery').doc(productId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Container();
          }
          
          final liveData = snapshot.data!.data() as Map<String, dynamic>;
          liveData['id'] = productId;
          
          return MachineryCard(
            machinery: liveData,
            isFavorite: true,
            onFavorite: () => _handleFavorite(context, buyerController),
            onRent: () => _handleRent(context, liveData),
          );
        },
      );
    } else {
      // It's crop or seed - fetch real-time data
      final productType = product.containsKey('variety') ? 'seeds' : 'crops';
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection(productType).doc(productId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Container();
          }
          
          final liveData = snapshot.data!.data() as Map<String, dynamic>;
          liveData['id'] = productId;
          
          return ProductCard(
            data: liveData,
            type: productType,
            isFavorite: true,
            onOrder: () => _showOrderDialog(context, liveData),
            onFavorite: () => _handleFavorite(context, buyerController),
          );
        },
      );
    }
  }

  void _handleFavorite(BuildContext context, BuyerController controller) {
    controller.addToFavorites(product);
    AppUtils.showSnackBar(context, 'Removed from favorites');
  }

  void _showOrderDialog(BuildContext context, [Map<String, dynamic>? liveData]) {
    final dataToUse = liveData ?? product;
    final productType = dataToUse.containsKey('variety') ? 'seeds' : 'crops';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderRentScreen(
          itemData: dataToUse,
          orderType: productType == 'crops' ? OrderType.crops : OrderType.seeds,
        ),
      ),
    );
  }

  void _handleRent(BuildContext context, [Map<String, dynamic>? liveData]) {
    final dataToUse = liveData ?? product;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderRentScreen(
          itemData: dataToUse,
          orderType: OrderType.machinery,
        ),
      ),
    );
  }
}