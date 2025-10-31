import 'package:flutter/material.dart';

import 'Helper/quick_action.dart';
import 'Helper/stats_row.dart';
import 'Helper/welcome_card.dart';

class HireLabourDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE65100).withOpacity(0.05), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelcomeCard(
              title: 'Labour Management',
              icon: Icons.engineering,
              color: Color(0xFFE65100),
            ),
            const SizedBox(height: 20),

            StatsRow(
              stats: [
                {'title': 'Active Workers', 'value': '28', 'icon': Icons.people},
                {'title': 'Earnings', 'value': '₹65,000', 'icon': Icons.work},
              ],
            ),
            const SizedBox(height: 20),

            QuickActions(
              actions: [
                {'title': 'Hire Workers', 'icon': Icons.person_add},
                {'title': 'Schedules', 'icon': Icons.schedule},
                {'title': 'Payments', 'icon': Icons.payment},
              ],
            ),
          ]),
        ),

    );
  }
}