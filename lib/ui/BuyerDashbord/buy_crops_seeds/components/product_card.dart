import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String type;
  final VoidCallback onOrder;
  final VoidCallback onFavorite;
  final bool isFavorite;

  const ProductCard({
    super.key,
    required this.data,
    required this.type,
    required this.onOrder,
    required this.onFavorite,
    this.isFavorite = false,
  });

  bool _isOutOfStock() {
    final stock = int.tryParse(data['stock']?.toString() ?? '0') ?? 0;
    final status = data['status']?.toString().toLowerCase() ?? '';
    return stock <= 0 || status.contains('out of stock');
  }

  Widget _buildStockBadge() {
    final stock = int.tryParse(data['stock']?.toString() ?? '0') ?? 0;
    String text;
    Color color;
    IconData icon;
    
    if (stock <= 0) {
      text = 'Not Available';
      color = Colors.red;
      icon = Icons.cancel;
    } else if (stock < 10) {
      text = 'Low Stock ($stock KG)';
      color = Colors.orange;
      icon = Icons.warning;
    } else {
      text = 'Available ($stock KG)';
      color = Colors.green;
      icon = Icons.check_circle;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  type == 'crops' ? Icons.grass : Icons.eco,
                  size: 30,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type == 'crops' ? 'Crop' : 'Seed',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Rs. ${(data['price'] is num ? (data['price'] as num).toInt() : data['price'])}/KG',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200], height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                data['location'] ?? 'N/A',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              const Spacer(),
              _buildStockBadge(),
            ],
          ),
          if (data['quality'] != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.verified, size: 18, color: Colors.green[700]),
                const SizedBox(width: 6),
                Text(
                  'Quality: ${data['quality']}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isOutOfStock() ? null : onOrder,
                  icon: Icon(
                    _isOutOfStock() ? Icons.block : Icons.shopping_cart, 
                    size: 18
                  ),
                  label: Text(_isOutOfStock() ? 'Out of Stock' : 'Order Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isOutOfStock() ? Colors.grey : const Color(0xFF2E5E25),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onFavorite,
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: isFavorite 
                          ? LinearGradient(
                              colors: [const Color(0xFF2E5E25), const Color(0xFF4A7C59)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [Colors.white, Colors.grey[50]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: isFavorite 
                              ? const Color(0xFF2E5E25).withOpacity(0.3)
                              : Colors.grey.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: isFavorite 
                            ? const Color(0xFF2E5E25)
                            : Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.white : const Color(0xFF2E5E25),
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
