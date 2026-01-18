import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductCard extends StatelessWidget {
  final DocumentSnapshot data;
  final String type;

  const ProductCard({
    super.key,
    required this.data,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final name = data['name']?.toString() ?? 'Unknown';
    final price = data['price']?.toString() ?? 'N/A';
    final stockValue = data['stock'];
    final stock = stockValue?.toString() ?? 'N/A';
    final unit = data['unit']?.toString() ?? '';
    
    // Safe stock parsing
    int stockInt = 0;
    if (stockValue != null) {
      if (stockValue is int) {
        stockInt = stockValue;
      } else if (stockValue is String) {
        stockInt = int.tryParse(stockValue) ?? 0;
      } else {
        stockInt = 0;
      }
    }
    
    // Adjust low stock threshold based on unit
    int lowStockThreshold = unit.toLowerCase() == 'ton' ? 2 : 10;
    
    final status = stockInt == 0
        ? "Out of Stock"
        : stockInt < lowStockThreshold
        ? "Low Stock"
        : "Available";

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            type == 'crops' ? Icons.agriculture : Icons.grass,
            color: Colors.green[700],
            size: 24,
          ),
        ),
        title: Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              'Price: Rs. ${price.contains('.') ? price.split('.')[0] : price} per $unit',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Stock: $stock $unit',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          itemBuilder: (context) => [
            PopupMenuItem(child: Text('Edit'), value: 'edit'),
            PopupMenuItem(child: Text('Delete'), value: 'delete'),
            PopupMenuItem(child: Text('View Details'), value: 'view'),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.green;
      case 'Low Stock':
        return Colors.orange;
      case 'Out of Stock':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}