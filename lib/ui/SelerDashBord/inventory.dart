import 'package:flutter/material.dart';

class InventoryDashboard extends StatelessWidget {
  const InventoryDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header with Enhanced Design
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[600]!, Colors.green[800]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
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
                        Text('Welcome Back!',
                            style: TextStyle(color: Colors.white70, fontSize: 14)),
                        Text('Seller Dashboard',
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Manage your agricultural products',
                            style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  )
                ],
              ),
            ),

            SizedBox(height: 24),

            // Enhanced Stats Cards
            Row(
              children: [
                _statCard('Total Products', '17', Icons.inventory, Colors.blue),
                SizedBox(width: 12),
                _statCard('Active Orders', '8', Icons.shopping_cart, Colors.orange),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                _statCard('Total Earnings', '₹45,000', Icons.monetization_on, Colors.green),
                SizedBox(width: 12),
                _statCard('This Month', '₹12,500', Icons.trending_up, Colors.purple),
              ],
            ),

            SizedBox(height: 24),

            // Action Buttons Section
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to add product form
                    },
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
                    onPressed: () {
                      // TODO: Navigate to orders
                    },
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

            // Recent Activity Section
            _sectionHeader('Recent Activity', Icons.history),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  _activityItem('New order received', 'Wheat - 50kg', '2 hours ago', Icons.shopping_bag, Colors.green),
                  Divider(),
                  _activityItem('Product updated', 'Rice - 25kg', '1 day ago', Icons.edit, Colors.blue),
                  Divider(),
                  _activityItem('Payment received', '₹5,000', '2 days ago', Icons.payment, Colors.orange),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Your Listings Section
            _sectionHeader('Your Listings', Icons.inventory_2),
            SizedBox(height: 12),
            ListView.builder(
              itemCount: 4,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final products = [
                  {'name': 'Wheat', 'weight': '50kg', 'price': '₹2,500', 'stock': '100 bags', 'status': 'Available'},
                  {'name': 'Rice', 'weight': '25kg', 'price': '₹1,800', 'stock': '50 bags', 'status': 'Low Stock'},
                  {'name': 'Corn', 'weight': '40kg', 'price': '₹2,200', 'stock': '75 bags', 'status': 'Available'},
                  {'name': 'Barley', 'weight': '30kg', 'price': '₹1,500', 'stock': '0 bags', 'status': 'Out of Stock'},
                ];

                final product = products[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5)),
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
                      child: Icon(Icons.eco, color: Colors.green[700], size: 24),
                    ),
                    title: Text('${product['name']} - ${product['weight']}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text('${product['price']} per bag',
                            style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
                        Text('Stock: ${product['stock']}',
                            style: TextStyle(color: Colors.grey[600])),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(product['status']!).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(product['status']!,
                              style: TextStyle(
                                color: _getStatusColor(product['status']!),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              )),
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
                    onTap: () {
                      // TODO: Open detail/edit page
                    },
                  ),
                );
              },
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Quick add product
        },
        backgroundColor: Colors.green[700],
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5)),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
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

  Widget _activityItem(String title, String subtitle, String time, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
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