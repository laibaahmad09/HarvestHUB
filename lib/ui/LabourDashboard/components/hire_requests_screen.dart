import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/labour_controller.dart';
import '../../../utils/app_utils.dart';

class HireRequestsScreen extends StatelessWidget {
  const HireRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LabourController>(
      builder: (context, labourController, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF1F9F1), Color(0xFFE8F5E8)],
            ),
          ),
          child: StreamBuilder(
            stream: labourController.getHireRequestsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work_off, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No hire requests yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('Complete your profile to start receiving requests', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final request = snapshot.data!.docs[index];
                  final requestData = request.data() as Map<String, dynamic>;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: const Color(0xFFF1F9F1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hire Request from ${requestData['farmerName'] ?? 'Farmer'}',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Duration: ${requestData['quantity'] ?? 'Not specified'} ${requestData['durationType'] ?? ''}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    Text(
                                      'Amount: Rs. ${requestData['totalAmount']?.toStringAsFixed(0) ?? '0'}',
                                      style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(requestData['status']),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  requestData['status']?.toString().toUpperCase() ?? 'PENDING',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (requestData['description'] != null)
                            Text(requestData['description']),
                          const SizedBox(height: 12),
                          Text(
                            'Requested on: ${_formatDate(requestData['requestedAt'])}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          
                          if (requestData['status'] == 'pending') ...[ 
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _respondToRequest(context, request.id, 'rejected'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Reject'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _respondToRequest(context, request.id, 'accepted'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Accept'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          
                          if (requestData['status'] == 'accepted') ...[
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    try {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  void _respondToRequest(BuildContext context, String requestId, String response) async {
    final labourController = Provider.of<LabourController>(context, listen: false);
    final success = await labourController.respondToHireRequest(requestId, response);
    
    if (success) {
      AppUtils.showSnackBar(context, 'Request ${response} successfully!');
    } else {
      AppUtils.showSnackBar(context, labourController.errorMessage ?? 'Failed to respond', isError: true);
    }
  }

  void _completeJob(BuildContext context, String requestId) async {
    final labourController = Provider.of<LabourController>(context, listen: false);
    final success = await labourController.completeJob(requestId);
    
    if (success) {
      AppUtils.showSnackBar(context, 'Job completed successfully!');
    } else {
      AppUtils.showSnackBar(context, labourController.errorMessage ?? 'Failed to complete job', isError: true);
    }
  }
}