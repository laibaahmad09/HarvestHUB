import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InventoryStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // First row - 2 cards
        Row(
          children: [
            _buildTotalOrdersCard(),
            SizedBox(width: 12),
            _buildTotalEarningsCard(),
          ],
        ),
        SizedBox(height: 12),
        // Second row - 2 cards
        Row(
          children: [
            _buildTodayEarningsCard(),
            SizedBox(width: 12),
_buildHiredWorkersCard(),
          ],
        ),
        SizedBox(height: 12),
        // Third row - 1 card
        Row(
          children: [
            Expanded(child: _buildRentedMachineryCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalOrdersCard() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return _buildStatCard('Total Orders', '0', Icons.inventory, Colors.blue);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').where('sellerId', isEqualTo: user.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildStatCard('Total Orders', '...', Icons.inventory, Colors.blue);
        }
        
        final ordersCount = snapshot.data!.docs.length;
        return _buildStatCard('Total Orders', ordersCount.toString(), Icons.inventory, Colors.blue);
      },
    );
  }

  Widget _buildTotalEarningsCard() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return _buildStatCard('Total Earnings', 'Rs. 0', Icons.account_balance_wallet, Colors.green);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').where('sellerId', isEqualTo: user.uid).where('status', isEqualTo: 'confirmed').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildStatCard('Total Earnings', 'Rs. ...', Icons.account_balance_wallet, Colors.green);
        }
        
        int totalEarnings = 0;
        
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final amount = data['totalAmount'];
          if (amount is num) {
            totalEarnings += amount.toInt();
          }
        }
        
        return _buildStatCard('Total Earnings', 'Rs. $totalEarnings', Icons.account_balance_wallet, Colors.green);
      },
    );
  }

  Widget _buildTodayEarningsCard() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return _buildStatCard('Today Earning', 'Rs. 0', Icons.today, Colors.orange);
    }

    return _buildStatCard('Today Earning', 'Rs. 0', Icons.today, Colors.orange);
  }

  Widget _buildHiredWorkersCard() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return _buildStatCard('Hired Workers', '0', Icons.people, Colors.purple);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('labour')
          .where('sellerId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'hired')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildStatCard('Hired Workers', '...', Icons.people, Colors.purple);
        }
        
        final hiredCount = snapshot.data!.docs.length;
        return _buildStatCard('Hired Workers', hiredCount.toString(), Icons.people, Colors.purple);
      },
    );
  }

  Widget _buildRentedMachineryCard() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return _buildStatCard('Rented Machinery', '0', Icons.agriculture, Colors.teal);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('machinery')
          .where('userId', isEqualTo: user.uid)
          .where('availability', isEqualTo: 'rented')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildStatCard('Rented Machinery', '0', Icons.agriculture, Colors.teal);
        }

        if (!snapshot.hasData) {
          return _buildStatCard('Rented Machinery', '...', Icons.agriculture, Colors.teal);
        }

        final rentedCount = snapshot.data!.docs.length;
        return _buildStatCard('Rented Machinery', rentedCount.toString(), Icons.agriculture, Colors.teal);
      },
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