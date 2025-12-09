import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../approutes/app_routes.dart';

class BuyerRentDashboard extends StatefulWidget {
  const BuyerRentDashboard({super.key});

  @override
  State<BuyerRentDashboard> createState() => _BuyerRentDashboardState();
}

class _BuyerRentDashboardState extends State<BuyerRentDashboard> {
  String selectedCategory = 'All';
  String selectedLocation = 'All';

  final List<String> categories = ['All', 'Tractor', 'Harvester', 'Plough', 'Cultivator', 'Thresher', 'Sprayer'];
  final List<String> locations = ['All', 'Lahore', 'Faisalabad', 'Multan', 'Gujranwala', 'Sialkot'];

  final List<Map<String, dynamic>> machineryData = [
    {
      'name': 'John Deere 5075E',
      'category': 'Tractor',
      'price': '₹2,500',
      'period': 'per day',
      'location': 'Lahore',
      'rating': 4.8,
      'reviews': 156,
      'owner': 'Muhammad Ali',
      'features': ['75 HP', 'AC Available', 'GPS Tracking'],
      'available': true,
      'image': 'tractor.jpg'
    },
    {
      'name': 'New Holland TC56',
      'category': 'Harvester',
      'price': '₹4,000',
      'period': 'per day',
      'location': 'Faisalabad',
      'rating': 4.6,
      'reviews': 89,
      'owner': 'Ahmed Hassan',
      'features': ['Combine Harvester', 'Fuel Efficient', 'Operator Included'],
      'available': true,
      'image': 'harvester.jpg'
    },
    {
      'name': 'Massey Ferguson 240',
      'category': 'Tractor',
      'price': '₹2,200',
      'period': 'per day',
      'location': 'Multan',
      'rating': 4.5,
      'reviews': 203,
      'owner': 'Fatima Sheikh',
      'features': ['50 HP', 'Good Condition', 'Trolley Available'],
      'available': false,
      'image': 'tractor2.jpg'
    },
    {
      'name': 'Kubota M6060',
      'category': 'Cultivator',
      'price': '₹1,800',
      'period': 'per day',
      'location': 'Sialkot',
      'rating': 4.7,
      'reviews': 67,
      'owner': 'Tariq Ahmad',
      'features': ['60 HP', 'Multi-Purpose', 'Well Maintained'],
      'available': true,
      'image': 'cultivator.jpg'
    },
  ];

  List<Map<String, dynamic>> get filteredMachinery {
    return machineryData.where((item) {
      bool categoryMatch = selectedCategory == 'All' || item['category'] == selectedCategory;
      bool locationMatch = selectedLocation == 'All' || item['location'] == selectedLocation;
      return categoryMatch && locationMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Rent Machinery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              _showFilterBottomSheet();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Available', '${machineryData.where((m) => m['available']).length}', Icons.check_circle),
                _buildStatItem('Categories', '${categories.length - 1}', Icons.category),
                _buildStatItem('Locations', '${locations.length - 1}', Icons.location_on),
              ],
            ),
          ),

          // Quick Filters
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quick Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownFilter('Category', selectedCategory, categories, (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      }),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdownFilter('Location', selectedLocation, locations, (value) {
                        setState(() {
                          selectedLocation = value!;
                        });
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Machinery List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredMachinery.length,
              itemBuilder: (context, index) {
                final machinery = filteredMachinery[index];
                return _buildMachineryCard(machinery);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add machinery screen
        },
        backgroundColor: Colors.green[700],
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('Add Machinery', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        SizedBox(height: 4),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(title, style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildDropdownFilter(String label, String value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(label),
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildMachineryCard(Map<String, dynamic> machinery) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Machinery Image Header
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                colors: [Colors.green[400]!, Colors.green[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    _getCategoryIcon(machinery['category']),
                    size: 80,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: machinery['available'] ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      machinery['available'] ? 'Available' : 'Rented',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      machinery['category'],
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Machinery Details
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        machinery['name'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          machinery['price'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          machinery['period'],
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Owner and Location
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(machinery['owner'], style: TextStyle(color: Colors.grey[600])),
                    SizedBox(width: 16),
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(machinery['location'], style: TextStyle(color: Colors.grey[600])),
                  ],
                ),

                SizedBox(height: 8),

                // Rating
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(
                      '${machinery['rating']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '(${machinery['reviews']} reviews)',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Features
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: machinery['features'].map<Widget>((feature) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        feature,
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: machinery['available'] ? () {
                          _showBookingDialog(machinery);
                        } : null,
                        icon: Icon(Icons.calendar_today, size: 16),
                        label: Text(machinery['available'] ? 'Book Now' : 'Not Available'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: machinery['available'] ? Colors.green[700] : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        _showDetailsDialog(machinery);
                      },
                      icon: Icon(Icons.info_outline, size: 16),
                      label: Text('Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green[700],
                        side: BorderSide(color: Colors.green[700]!),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Tractor':
        return Icons.agriculture;
      case 'Harvester':
        return Icons.grass;
      case 'Plough':
        return Icons.terrain;
      case 'Cultivator':
        return Icons.eco;
      case 'Thresher':
        return Icons.grain;
      case 'Sprayer':
        return Icons.water_drop;
      default:
        return Icons.build;
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text('Price Range', style: TextStyle(fontWeight: FontWeight.w500)),
              SizedBox(height: 10),
              // Add price range slider here
              SizedBox(height: 20),
              Text('Availability', style: TextStyle(fontWeight: FontWeight.w500)),
              SizedBox(height: 10),
              // Add availability checkboxes here
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Apply Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBookingDialog(Map<String, dynamic> machinery) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Book ${machinery['name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select rental duration:'),
              SizedBox(height: 10),
              // Add date pickers and duration selection
              TextField(
                decoration: InputDecoration(
                  labelText: 'Number of days',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Process booking
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Booking request sent!')),
                );
              },
              child: Text('Book'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDetailsDialog(Map<String, dynamic> machinery) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(machinery['name']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category: ${machinery['category']}'),
              Text('Owner: ${machinery['owner']}'),
              Text('Location: ${machinery['location']}'),
              Text('Price: ${machinery['price']} ${machinery['period']}'),
              Text('Rating: ${machinery['rating']} (${machinery['reviews']} reviews)'),
              SizedBox(height: 10),
              Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...machinery['features'].map<Widget>((feature) => Text('• $feature')).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
            if (machinery['available'])
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showBookingDialog(machinery);
                },
                child: Text('Book Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red[600]),
            SizedBox(width: 8),
            Text('Logout'),
          ],
        ),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authController = Provider.of<AuthController>(context, listen: false);
              await authController.logout();
              AppRoutes.navigateAndClearStack(context, AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}