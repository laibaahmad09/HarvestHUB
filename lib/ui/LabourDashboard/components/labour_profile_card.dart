import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/labour_controller.dart';
import '../../../utils/app_utils.dart';
import 'labour_profile_detail.dart';
import 'labour_registration_form.dart';

class LabourProfileCard extends StatelessWidget {
  const LabourProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LabourController>(
      builder: (context, labourController, child) {
        final profile = labourController.labourProfile;
        if (profile == null) return const SizedBox();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => _viewProfile(context, profile),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFF2E5E25),
                      child: Text(
                        profile['name']?.toString().substring(0, 1).toUpperCase() ?? 'L',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile['name'] ?? 'Labour',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            profile['phone'] ?? '',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: profile['isAvailable'] == true ? Colors.green : Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              profile['isAvailable'] == true ? 'Available' : 'Busy',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuAction(context, value, profile),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.visibility), SizedBox(width: 8), Text('View Details')])),
                        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit Profile')])),
                        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Delete Profile', style: TextStyle(color: Colors.red))])),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Experience: ${profile['experience'] ?? 'Not specified'}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                if (profile['skills'] != null && (profile['skills'] as List).isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: (profile['skills'] as List).take(3).map((skill) => 
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E5E25).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(skill.toString(), style: const TextStyle(fontSize: 12)),
                      )
                    ).toList(),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.money, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _getPriceText(profile),
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const Spacer(),
                    const Icon(Icons.touch_app, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text('Tap to view details', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _viewProfile(BuildContext context, Map<String, dynamic> profile) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LabourProfileDetail(profile: profile)),
    );
  }

  void _handleMenuAction(BuildContext context, String action, Map<String, dynamic> profile) {
    switch (action) {
      case 'view':
        _viewProfile(context, profile);
        break;
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LabourRegistrationForm(isEditing: true)),
        );
        break;
      case 'delete':
        _showDeleteDialog(context);
        break;
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile'),
        content: const Text('Are you sure you want to delete your profile? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _deleteProfile(context),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _getPriceText(Map<String, dynamic> profile) {
    final dailyRate = profile['dailyRate'] ?? 0;
    final hourlyRate = profile['hourlyRate'] ?? 0;
    
    if (dailyRate > 0) {
      return 'Rs $dailyRate/day';
    } else if (hourlyRate > 0) {
      return 'Rs $hourlyRate/hour';
    } else {
      return 'Rate not set';
    }
  }

  void _deleteProfile(BuildContext context) async {
    Navigator.pop(context);
    final labourController = Provider.of<LabourController>(context, listen: false);
    final success = await labourController.deleteProfile();
    
    if (success) {
      AppUtils.showSnackBar(context, 'Profile deleted successfully!');
    } else {
      AppUtils.showSnackBar(context, 'Failed to delete profile', isError: true);
    }
  }
}