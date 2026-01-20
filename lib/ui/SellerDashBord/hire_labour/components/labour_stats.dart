import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../services/auth_service.dart';

class LabourStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildTotalWorkersCard(),
        const SizedBox(width: 12),
        _buildHiredWorkersCard(),
      ],
    );
  }

  Widget _buildTotalWorkersCard() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('labour_profiles')
            .snapshots(),
        builder: (context, snapshot) {
          final totalWorkers = snapshot.hasData ? snapshot.data!.docs.length : 0;
          return _buildStatCard('Total Workers', totalWorkers.toString(), Icons.people, Colors.green);
        },
      ),
    );
  }

  Widget _buildHiredWorkersCard() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _getHiredWorkersStream(),
        builder: (context, snapshot) {
          final hiredWorkers = snapshot.hasData ? snapshot.data!.docs.length : 0;
          return _buildStatCard('Hired Workers', hiredWorkers.toString(), Icons.work, Colors.green);
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getHiredWorkersStream() async* {
    final sellerId = await AuthService.getUserId();
    if (sellerId == null) return;
    
    yield* FirebaseFirestore.instance
        .collection('hire_requests')
        .where('sellerId', isEqualTo: sellerId)
        .where('status', isEqualTo: 'accepted')
        .snapshots();
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.green[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.green.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[400]!, Colors.green[600]!],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 28, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}