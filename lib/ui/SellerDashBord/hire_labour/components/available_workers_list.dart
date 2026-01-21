import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../services/auth_service.dart';
import '../../../../utils/app_utils.dart';
import 'hire_labour_screen.dart';

class AvailableWorkersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('labour_profiles')
          .where('isAvailable', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('No available labourers', style: TextStyle(fontSize: 18, color: Colors.grey)),
                SizedBox(height: 8),
                Text('Labourers will appear here once they register', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final labourer = doc.data() as Map<String, dynamic>;
            labourer['id'] = doc.id;
            return _buildLabourCard(context, labourer);
          },
        );
      },
    );
  }

  Widget _buildLabourCard(BuildContext context, Map<String, dynamic> labourer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.green[100],
                  child: Icon(Icons.person, color: Colors.green[700], size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labourer['name'] ?? 'Unknown',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        (labourer['skills'] as List<dynamic>?)?.first?.toString() ?? 'General Work',
                        style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${labourer['rating'] ?? 0.0} • ${labourer['experience'] ?? 'No experience'}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (labourer['isAvailable'] == true) ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    (labourer['isAvailable'] == true) ? 'Available' : 'Busy',
                    style: TextStyle(
                      color: (labourer['isAvailable'] == true) ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                const SizedBox(width: 4),
                Text(labourer['address'] ?? 'Location not provided', style: TextStyle(color: Colors.grey[600])),
                const Spacer(),
                Text(
                  _getPriceText(labourer),
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (labourer['skills'] != null && (labourer['skills'] as List).isNotEmpty)
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: (labourer['skills'] as List<dynamic>).take(3).map<Widget>((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      skill.toString(),
                      style: TextStyle(color: Colors.blue[700], fontSize: 10),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (labourer['isAvailable'] == true) ? () {
                  print('Labourer data being passed: $labourer');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HireLabourScreen(labourer: labourer),
                    ),
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: (labourer['isAvailable'] == true) ? Colors.green[700] : Colors.grey[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  (labourer['isAvailable'] == true) ? 'Hire Now' : 'Not Available',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPriceText(Map<String, dynamic> labourer) {
    final dailyRate = labourer['dailyRate'] ?? 0;
    final hourlyRate = labourer['hourlyRate'] ?? 0;
    
    if (dailyRate > 0) {
      return 'Rs. $dailyRate/day';
    } else if (hourlyRate > 0) {
      return 'Rs. $hourlyRate/hour';
    } else {
      return 'Rate not set';
    }
  }

  void _showHireDialog(BuildContext context, Map<String, dynamic> labourer) {
    final durationController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E5E25), Color(0xFF4A7A4C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.work, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Hire ${labourer['name']}',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F9F1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2E5E25).withOpacity(0.2)),
                ),
                child: TextField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration (e.g., 5 days)',
                    labelStyle: TextStyle(color: Color(0xFF2E5E25)),
                    prefixIcon: Icon(Icons.schedule, color: Color(0xFF2E5E25)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F9F1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2E5E25).withOpacity(0.2)),
                ),
                child: TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Work Description',
                    labelStyle: TextStyle(color: Color(0xFF2E5E25)),
                    prefixIcon: Icon(Icons.description, color: Color(0xFF2E5E25)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  maxLines: 3,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (durationController.text.isNotEmpty) {
                await _sendHireRequest(context, labourer, durationController.text, descriptionController.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E5E25),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.send, size: 18),
                SizedBox(width: 8),
                Text('Send Request', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendHireRequest(BuildContext context, Map<String, dynamic> labourer, String duration, String description) async {
    try {
      final sellerId = await AuthService.getUserId();
      if (sellerId == null) return;

      // Get seller info
      final sellerDoc = await FirebaseFirestore.instance.collection('users').doc(sellerId).get();
      final sellerName = sellerDoc.data()?['name'] ?? 'Farmer';

      await FirebaseFirestore.instance.collection('hire_requests').add({
        'labourId': labourer['userId'],
        'sellerId': sellerId,
        'farmerName': sellerName,
        'labourName': labourer['name'],
        'duration': duration,
        'description': description,
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
        'dailyRate': labourer['dailyRate'],
        'hourlyRate': labourer['hourlyRate'],
      });

      AppUtils.showSnackBar(context, 'Hire request sent successfully!');
    } catch (e) {
      AppUtils.showSnackBar(context, 'Failed to send hire request', isError: true);
    }
  }
}