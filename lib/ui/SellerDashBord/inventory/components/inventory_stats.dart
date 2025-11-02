import 'package:flutter/material.dart';

class InventoryStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // First row - 2 cards
        Row(
          children: [
            _buildStatCard('Total Products', '45', Icons.inventory, Colors.blue),
            SizedBox(width: 12),
            _buildStatCard('Total Earnings', '₹85,000', Icons.account_balance_wallet, Colors.green),
          ],
        ),
        SizedBox(height: 12),
        // Second row - 2 cards
        Row(
          children: [
            _buildStatCard('This Month', '₹12,500', Icons.calendar_month, Colors.orange),
            SizedBox(width: 12),
            _buildStatCard('Hired Workers', '8', Icons.people, Colors.purple),
          ],
        ),
        SizedBox(height: 12),
        // Third row - 1 card
        _buildStatCard('Rental Products', '12', Icons.agriculture, Colors.teal),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, size: 24, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}