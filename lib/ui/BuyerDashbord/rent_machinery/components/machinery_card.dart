import 'package:flutter/material.dart';
import 'dart:convert';

class MachineryCard extends StatelessWidget {
  final Map<String, dynamic> machinery;
  final VoidCallback onFavorite;
  final VoidCallback onRent;
  final bool isFavorite;

  const MachineryCard({
    super.key,
    required this.machinery,
    required this.onFavorite,
    required this.onRent,
    this.isFavorite = false,
  });

  bool _isAvailable() {
    final availability = machinery['availability']?.toString().toLowerCase() ?? 'available';
    print('Machinery ${machinery['name']} availability: $availability');
    return availability == 'available';
  }

  @override
  Widget build(BuildContext context) {
    final priceValue = machinery['pricePerDay'] ?? 0;
    final price = priceValue is num ? priceValue.toInt().toString() : priceValue.toString();
    final imageBase64 = machinery['imageBase64'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Machinery Image
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              color: Colors.grey[200],
            ),
            child: Stack(
              children: [
                imageBase64 != null && imageBase64.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.memory(
                          base64Decode(imageBase64),
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Icon(Icons.agriculture, size: 60, color: Colors.grey[400]),
                      ),

                Positioned(
                  top: 8,
                  left: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onFavorite,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: const Color(0xFF2E5E25),
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Machinery Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            machinery['name'] ?? 'Unknown Machinery',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  machinery['location'] ?? 'N/A',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rs. $price/day',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E5E25),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildAvailabilityBadge(machinery['availability'] ?? machinery['status'] ?? 'Available'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (machinery['description'] != null) ...[
                  Text(
                    machinery['description'],
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isAvailable() ? onRent : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAvailable() ? const Color(0xFF2E5E25) : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isAvailable() ? 'Rent Now' : 'Not Available',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildAvailabilityBadge(String status) {
    Color badgeColor;
    Color textColor;
    String displayText = status;
    
    switch (status.toLowerCase()) {
      case 'available':
        badgeColor = Colors.green;
        textColor = Colors.green;
        displayText = 'Available';
        break;
      case 'rented':
      case 'unavailable':
        badgeColor = Colors.red;
        textColor = Colors.red;
        displayText = 'Rented';
        break;
      case 'maintenance':
        badgeColor = Colors.orange;
        textColor = Colors.orange;
        displayText = 'Maintenance';
        break;
      default:
        badgeColor = Colors.green;
        textColor = Colors.green;
        displayText = 'Available';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}