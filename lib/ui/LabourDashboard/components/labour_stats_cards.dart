import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/labour_controller.dart';
import '../../common/stat_card.dart';

class LabourStatsCards extends StatelessWidget {
  const LabourStatsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LabourController>(
      builder: (context, labourController, child) {
        final profile = labourController.labourProfile;
        if (profile == null) return const SizedBox();

        return Row(
          children: [
            StatCard(
              title: 'Total Jobs',
              value: '${profile['totalJobs'] ?? 0}',
              icon: Icons.work,
              color: Colors.blue,
            ),
            const SizedBox(width: 12),
            StatCard(
              title: 'Total Earning',
              value: 'Rs ${profile['totalEarning'] ?? 0}',
              icon: Icons.account_balance_wallet,
              color: Colors.green,
            ),
            const SizedBox(width: 12),
            StatCard(
              title: 'Today Earning',
              value: 'Rs ${profile['todayEarning'] ?? 0}',
              icon: Icons.today,
              color: Colors.orange,
            ),
          ],
        );
      },
    );
  }
}