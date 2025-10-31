import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/product_controller.dart';
import 'product_card.dart';

class ProductList extends StatelessWidget {
  final String collection;

  const ProductList({
    super.key,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, productController, child) {
        if (productController.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final products = collection == 'crops'
            ? productController.crops
            : productController.seeds;

        if (products.isEmpty) {
          return Text(
            "No $collection added yet.",
            style: TextStyle(color: Colors.grey),
          );
        }

        return ListView.builder(
          itemCount: products.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final data = products[index];
            return ProductCard(data: data, type: collection);
          },
        );
      },
    );
  }
}