import 'package:flutter/material.dart';

class MachineryCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const MachineryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['name'] ?? 'Unnamed';
    final price = data['pricePerDay']?.toString() ?? '0';
    final location = data['location'] ?? 'Unknown';
    final imageUrl = data['imageUrl'] ?? '';
    final available = data['isAvailable'] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 160,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Icon(Icons.image, size: 40, color: Colors.grey[600]),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Location: $location',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  'Price/Day: ₹$price',
                  style: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: available ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    available ? 'Available for Rent' : 'Not Available',
                    style: TextStyle(
                      color: available ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
