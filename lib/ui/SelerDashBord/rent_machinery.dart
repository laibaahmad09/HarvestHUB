import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../approutes/app_routes.dart';
import '../../services/auth_service.dart';


class RentDashboard extends StatefulWidget {
  const RentDashboard({super.key});

  @override
  State<RentDashboard> createState() => _RentDashboardState();
}

class _RentDashboardState extends State<RentDashboard> with TickerProviderStateMixin {
  String selectedCategory = 'All';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> categories = [
    'All',
    'Tractor',
    'Harvester',
    'Plough',
    'Cultivator',
    'Thresher',
    'Sprayer',
  ];
  Stream<QuerySnapshot> getMachineryStream() async* {
    String? userId = await AuthService.getUserId();
    if (userId == null) return;
    
    if (selectedCategory == 'All') {
      yield* FirebaseFirestore.instance
          .collection('machinery')
          .where('userId', isEqualTo: userId)
          .snapshots();
    } else {
      yield* FirebaseFirestore.instance
          .collection('machinery')
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: selectedCategory)
          .snapshots();
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  backgroundColor: const Color(0xFF2E7D32),
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      'Rent Machinery',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1B5E20), Color(0xFF43A047), Color(0xFF66BB6A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -50,
                            top: -50,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(75),
                              ),
                            ),
                          ),
                          Positioned(
                            left: -30,
                            bottom: -30,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const SizedBox(height: 13),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.filter_alt_outlined, color: Color(0xFF43A047), size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Filter by Category',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildDropdownFilter(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: getMachineryStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No machinery found.'));
                      }

                      final docs = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          return _buildMachineryCard(data);
                        },
                      );
                    },
                  ),
                ),

              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoCard('Total', '12', Icons.precision_manufacturing, const Color(0xFF388E3C)),
                  _buildInfoCard('Rented', '4', Icons.agriculture, const Color(0xFF388E3C)),
                  _buildInfoCard('Available', '8', Icons.check_circle_outline, const Color(0xFF388E3C)),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AppRoutes.navigateTo(context, AppRoutes.addMachinery);
        },
        backgroundColor: const Color(0xFF43A047),
        elevation: 8,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Machinery',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
  Widget _buildMachineryCard(Map<String, dynamic> data) {
    final name = data['name'] ?? 'Unnamed';
    final price = data['pricePerDay']?.toString() ?? '0';
    final location = data['location'] ?? 'Unknown';
    final imageUrl = data['imageUrl'] ?? '';
    final available = data['isAvailable'] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: imageUrl.isNotEmpty
                ? Image.network(imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover)
                : Container(
              height: 160,
              width: double.infinity,
              color: Colors.grey[300],
              child: Icon(Icons.image, size: 40, color: Colors.grey[600]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Location: $location', style: TextStyle(color: Colors.grey[600])),
                Text('Price/Day: ₹$price', style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.w600)),
                SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: available ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    available ? 'Available for Rent' : 'Not Available',
                    style: TextStyle(
                      color: available ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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

  Widget _buildInfoCard(String title, String value, IconData icon, Color bgColor) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: Colors.white),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }
  Widget _buildDropdownFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF43A047).withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategory,
          isExpanded: true,
          dropdownColor: Colors.white,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF43A047)),
          items: categories.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  Icon(
                    item == 'All' ? Icons.all_inclusive : Icons.agriculture,
                    size: 16,
                    color: const Color(0xFF43A047),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF2E7D32)),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedCategory = value;
              });
            }
          },
        ),
      ),
    );
  }
}
