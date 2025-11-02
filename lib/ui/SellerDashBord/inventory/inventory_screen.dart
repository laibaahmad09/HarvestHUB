import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';

class InventoryDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppColors.backgroundDecoration,
        child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            Row(
              children: [
                _buildStatCard('Total Products', '45', Icons.inventory, Colors.blue),
                SizedBox(width: 12),
                _buildStatCard('Total Earnings', '₹85,000', Icons.account_balance_wallet, Colors.green),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard('This Month', '₹12,500', Icons.calendar_month, Colors.orange),
                SizedBox(width: 12),
                _buildStatCard('Hired Workers', '8', Icons.people, Colors.purple),
              ],
            ),
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              child: _buildStatCard('Rental Products', '12', Icons.agriculture, Colors.teal),
            ),
            SizedBox(height: 24),
            
            // Your Listings
            Text(
              'Your Listings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            
            // Sample Listings
            _buildListingCard('Wheat Premium', 'Crop', '₹50/KG', 'Active'),
            _buildListingCard('Rice Basmati', 'Crop', '₹80/KG', 'Active'),
            _buildListingCard('Tractor JD 5050', 'Machinery', '₹2500/day', 'Rented'),
            _buildListingCard('Corn Seeds', 'Seeds', '₹120/KG', 'Low Stock'),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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
                color: color,
                borderRadius: BorderRadius.circular(12),
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

  Widget _buildListingCard(String name, String type, String price, String status) {
    Color statusColor = status == 'Active' ? Colors.green : 
                       status == 'Rented' ? Colors.blue : Colors.orange;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green[600],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.inventory, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$type • $price',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}