import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../utils/app_colors.dart';

class InventoryDashboard extends StatefulWidget {
  const InventoryDashboard({super.key});

  @override
  State<InventoryDashboard> createState() => _InventoryDashboardState();
}

class _InventoryDashboardState extends State<InventoryDashboard> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppColors.backgroundDecoration,
        child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            Row(
              children: [
                _buildTotalProductsCard(),
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
              child: _buildRentalProductsCard(),
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
            
            // Real Firebase Listings
            _buildFirebaseListings(),
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

  Widget _buildFirebaseListings() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    
    if (userId == null) {
      return Center(
        child: Text(
          'Please login to view your listings',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('crops').where('userId', isEqualTo: userId).snapshots(),
      builder: (context, cropsSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('seeds').where('userId', isEqualTo: userId).snapshots(),
          builder: (context, seedsSnapshot) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('machinery').where('userId', isEqualTo: userId).snapshots(),
              builder: (context, machinerySnapshot) {
                if (!cropsSnapshot.hasData || !seedsSnapshot.hasData || !machinerySnapshot.hasData) {
                  return SizedBox();
                }
                
                List<Widget> allListings = [];
                
                // Add crops
                for (var doc in cropsSnapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  allListings.add(_buildListingCard(
                    data['name'] ?? 'Unknown Crop',
                    'Crop',
                    '₹${data['price']}/KG',
                    'Active',
                  ));
                }
                
                // Add seeds
                for (var doc in seedsSnapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  allListings.add(_buildListingCard(
                    data['name'] ?? 'Unknown Seed',
                    'Seeds',
                    '₹${data['price']}/KG',
                    'Active',
                  ));
                }
                
                // Add machinery
                for (var doc in machinerySnapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  allListings.add(_buildListingCard(
                    data['name'] ?? 'Unknown Machine',
                    'Machinery',
                    '₹${data['pricePerDay']}/day',
                    data['isAvailable'] == true ? 'Available' : 'Rented',
                  ));
                }
                
                if (allListings.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text(
                        'No products added yet',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }
                
                return Column(children: allListings);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTotalProductsCard() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return _buildStatCard('Total Products', '0', Icons.inventory, Colors.blue);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('crops').where('userId', isEqualTo: userId).snapshots(),
      builder: (context, cropsSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('seeds').where('userId', isEqualTo: userId).snapshots(),
          builder: (context, seedsSnapshot) {
            if (!cropsSnapshot.hasData || !seedsSnapshot.hasData) {
              return _buildStatCard('Total Products', 'Loading...', Icons.inventory, Colors.blue);
            }
            
            final cropsCount = cropsSnapshot.data!.docs.length;
            final seedsCount = seedsSnapshot.data!.docs.length;
            final totalCount = cropsCount + seedsCount;
            
            return _buildStatCard('Total Products', '$totalCount', Icons.inventory, Colors.blue);
          },
        );
      },
    );
  }

  Widget _buildRentalProductsCard() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return _buildStatCard('Rental Products', '0', Icons.agriculture, Colors.teal);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('machinery').where('userId', isEqualTo: userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildStatCard('Rental Products', 'Loading...', Icons.agriculture, Colors.teal);
        }
        
        final machineryCount = snapshot.data!.docs.length;
        return _buildStatCard('Rental Products', '$machineryCount', Icons.agriculture, Colors.teal);
      },
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