import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import 'components/labour_stats.dart';
import 'components/available_workers_list.dart';
import 'components/hired_workers_list.dart';

class HireLabourDashboard extends StatefulWidget {
  const HireLabourDashboard({super.key});

  @override
  State<HireLabourDashboard> createState() => _HireLabourDashboardState();
}

class _HireLabourDashboardState extends State<HireLabourDashboard> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppColors.backgroundDecoration,
        child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabourStats(),
            SizedBox(height: 24),
_buildTabSelector(),
            SizedBox(height: 16),
            selectedTab == 0 ? AvailableWorkersList() : HiredWorkersList(),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = 0),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedTab == 0 ? Colors.green[600] : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Available',
                    style: TextStyle(
                      color: selectedTab == 0 ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = 1),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedTab == 1 ? Colors.green[600] : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Hired',
                    style: TextStyle(
                      color: selectedTab == 1 ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}