import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/approutes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:first_project/services/auth_service.dart';


class SellDashboard extends StatelessWidget {
  const SellDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 24),
            Row(
              children: [
                _buildStatCountCard('crops', 'Total Crops', Icons.inventory, Colors.blue),
                SizedBox(width: 12),
                _buildStatCountCard('seeds', 'Total Seeds', Icons.shopping_cart, Colors.orange),
              ],
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => AppRoutes.navigateTo(context, AppRoutes.addProduct),
                    icon: Icon(Icons.add, color: Colors.white),
                    label: Text('Add Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.list_alt, color: Colors.green[700]),
                    label: Text('View Orders', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.green[700]!, width: 2),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            _sectionHeader('Crops', Icons.agriculture),
            SizedBox(height: 8),
            _streamList(collection: 'crops'),
            SizedBox(height: 20),
            _sectionHeader('Seeds', Icons.grass),
            SizedBox(height: 8),
            _streamList(collection: 'seeds'),
            SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AppRoutes.navigateTo(context, AppRoutes.addProduct),
        backgroundColor: Colors.green[700],
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[600]!, Colors.green[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 15, offset: Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.storefront, color: Colors.white, size: 32),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome Back!', style: TextStyle(color: Colors.white70, fontSize: 14)),
                Text('Seller Dashboard', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Manage your agricultural products', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }
  Widget _buildStatCountCard(String collection, String title, IconData icon, Color color) {
    return Expanded(
      child: FutureBuilder<String?>(
        future: AuthService.getUserId(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) return _statCard(title, '...', icon, color);
          
          return FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection(collection)
                .where('userId', isEqualTo: userSnapshot.data!)
                .get(),
            builder: (context, snapshot) {
              String count = snapshot.hasData ? snapshot.data!.docs.length.toString() : '...';
              return _statCard(title, count, icon, color);
            },
          );
        },
      ),
    );
  }

  Widget _streamList({required String collection}) {
    return FutureBuilder<String?>(
      future: AuthService.getUserId(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(collection)
              .where('userId', isEqualTo: userSnapshot.data!)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Text("No $collection added yet.", style: TextStyle(color: Colors.grey));
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final data = snapshot.data!.docs[index];
                return _listingCard(data, collection);
              },
            );
          },
        );
      },
    );
  }

  Widget _listingCard(DocumentSnapshot data, String type) {
    final name = data['name'] ?? 'Unknown';
    final price = data['price'] ?? 'N/A';
    final stock = data['stock'] ?? 'N/A';
    final unit = data['unit'] ?? '';
    final status = stock == "0" ? "Out of Stock" : int.tryParse(stock)! < 10 ? "Low Stock" : "Available";

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(type == 'crops' ? Icons.agriculture : Icons.grass, color: Colors.green[700], size: 24),
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text('Price: ₹$price per $unit', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
            Text('Stock: $stock $unit', style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(status, style: TextStyle(color: _getStatusColor(status), fontSize: 12, fontWeight: FontWeight.bold)),
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

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5))],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 24, color: color),
            ),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.green[700], size: 24),
        SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
      ],
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


