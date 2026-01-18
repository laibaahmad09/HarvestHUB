import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../utils/app_colors.dart';
import '../../../services/order_service.dart';

class InventoryDashboard extends StatefulWidget {
  const InventoryDashboard({super.key});

  @override
  State<InventoryDashboard> createState() => _InventoryDashboardState();
}

class _InventoryDashboardState extends State<InventoryDashboard> {

  @override
  void initState() {
    super.initState();
    // Clean up orphaned machinery when inventory screen loads
    OrderService.updateExpiredRentals();
  }

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
                _buildTotalOrdersCard(),
                SizedBox(width: 12),
                _buildTotalEarningsCard(),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                _buildThisMonthEarningsCard(),
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
                  final stock = int.tryParse(data['stock']?.toString() ?? '0') ?? 0;
                  final status = stock > 10 ? 'In Stock' : (stock > 0 ? 'Low Stock' : 'Out of Stock');
                  
                  allListings.add(_buildListingCard(
                    data['name'] ?? 'Unknown Crop',
                    'Crop',
                    'Rs. ${(data['price'] is num ? (data['price'] as num).toInt() : data['price'])}/KG',
                    status,
                  ));
                }
                
                // Add seeds
                for (var doc in seedsSnapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final stock = int.tryParse(data['stock']?.toString() ?? '0') ?? 0;
                  final status = stock > 10 ? 'In Stock' : (stock > 0 ? 'Low Stock' : 'Out of Stock');
                  
                  allListings.add(_buildListingCard(
                    data['name'] ?? 'Unknown Seed',
                    'Seeds',
                    'Rs. ${(data['price'] is num ? (data['price'] as num).toInt() : data['price'])}/KG',
                    status,
                  ));
                }
                
                // Add machinery
                for (var doc in machinerySnapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final availability = data['availability']?.toString().toLowerCase() ?? 'available';
                  final status = availability == 'rented' ? 'Rented' : 'Available';
                  
                  allListings.add(_buildListingCard(
                    data['name'] ?? 'Unknown Machine',
                    'Machinery',
                    'Rs. ${(data['pricePerDay'] is num ? (data['pricePerDay'] as num).toInt() : data['pricePerDay'])}/day',
                    status,
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

  Widget _buildTotalOrdersCard() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return _buildStatCard('Total Orders', '0', Icons.inventory, Colors.blue);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').where('sellerId', isEqualTo: userId).snapshots(),
      builder: (context, ordersSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('rentals').where('sellerId', isEqualTo: userId).snapshots(),
          builder: (context, rentalsSnapshot) {
            if (!ordersSnapshot.hasData || !rentalsSnapshot.hasData) {
              return _buildStatCard('Total Orders', '...', Icons.inventory, Colors.blue);
            }
            
            final ordersCount = ordersSnapshot.data!.docs.length;
            final rentalsCount = rentalsSnapshot.data!.docs.length;
            final totalCount = ordersCount + rentalsCount;
            
            return _buildStatCard('Total Orders', '$totalCount', Icons.inventory, Colors.blue);
          },
        );
      },
    );
  }

  Widget _buildTotalEarningsCard() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return _buildStatCard('Total Earnings', 'Rs. 0', Icons.account_balance_wallet, Colors.green);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').where('sellerId', isEqualTo: userId).where('status', isEqualTo: 'confirmed').snapshots(),
      builder: (context, ordersSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('rentals').where('sellerId', isEqualTo: userId).where('status', isEqualTo: 'confirmed').snapshots(),
          builder: (context, rentalsSnapshot) {
            if (!ordersSnapshot.hasData || !rentalsSnapshot.hasData) {
              return _buildStatCard('Total Earnings', 'Rs. ...', Icons.account_balance_wallet, Colors.green);
            }
            
            int totalEarnings = 0;
            
            // Add confirmed orders earnings
            for (var doc in ordersSnapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final amount = data['totalAmount'];
              if (amount is num) {
                totalEarnings += amount.toInt();
              }
            }
            
            // Add confirmed rentals earnings
            for (var doc in rentalsSnapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final amount = data['totalAmount'];
              if (amount is num) {
                totalEarnings += amount.toInt();
              }
            }
            
            return _buildStatCard('Total Earnings', 'Rs. $totalEarnings', Icons.account_balance_wallet, Colors.green);
          },
        );
      },
    );
  }

  Widget _buildThisMonthEarningsCard() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return _buildStatCard('Today Earning', 'Rs. 0', Icons.today, Colors.orange);
    }

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('sellerId', isEqualTo: userId)
          .where('status', isEqualTo: 'confirmed')
          .snapshots(),
      builder: (context, ordersSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('rentals')
              .where('sellerId', isEqualTo: userId)
              .where('status', isEqualTo: 'confirmed')
              .snapshots(),
          builder: (context, rentalsSnapshot) {
            if (!ordersSnapshot.hasData || !rentalsSnapshot.hasData) {
              return _buildStatCard('Today Earning', 'Rs. ...', Icons.today, Colors.orange);
            }
            
            int todayEarnings = 0;
            
            // Filter orders by today
            for (var doc in ordersSnapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final orderDate = data['orderDate'] as Timestamp?;
              if (orderDate != null) {
                final date = orderDate.toDate();
                if (date.year == now.year && date.month == now.month && date.day == now.day) {
                  final amount = data['totalAmount'];
                  if (amount is num) {
                    todayEarnings += amount.toInt();
                  }
                }
              }
            }
            
            // Filter rentals by today
            for (var doc in rentalsSnapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final requestDate = data['requestDate'] as Timestamp?;
              if (requestDate != null) {
                final date = requestDate.toDate();
                if (date.year == now.year && date.month == now.month && date.day == now.day) {
                  final amount = data['totalAmount'];
                  if (amount is num) {
                    todayEarnings += amount.toInt();
                  }
                }
              }
            }
            
            return _buildStatCard('Today Earning', 'Rs. $todayEarnings', Icons.today, Colors.orange);
          },
        );
      },
    );
  }

  Widget _buildRentalProductsCard() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return _buildStatCard('Rented Machinery', '0', Icons.agriculture, Colors.teal);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('machinery')
          .where('userId', isEqualTo: userId)
          .where('availability', isEqualTo: 'rented')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildStatCard('Rented Machinery', '...', Icons.agriculture, Colors.teal);
        }
        
        final rentedCount = snapshot.data!.docs.length;
        return _buildStatCard('Rented Machinery', '$rentedCount', Icons.agriculture, Colors.teal);
      },
    );
  }

  Widget _buildListingCard(String name, String type, String price, String status) {
    Color statusColor;
    switch (status) {
      case 'In Stock':
      case 'Available':
        statusColor = Colors.green;
        break;
      case 'Low Stock':
        statusColor = Colors.orange;
        break;
      case 'Out of Stock':
        statusColor = Colors.red;
        break;
      case 'Rented':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }
    
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