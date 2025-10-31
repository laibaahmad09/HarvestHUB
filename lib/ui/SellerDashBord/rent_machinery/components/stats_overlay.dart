import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/machinery_controller.dart';
import 'info_card.dart';

class StatsOverlay extends StatelessWidget {
  const StatsOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Consumer<MachineryController>(
              builder: (context, controller, child) {
                return InfoCard(
                  title: 'Total',
                  value: controller.getTotalCount().toString(),
                  icon: Icons.precision_manufacturing,
                  bgColor: const Color(0xFF388E3C),
                );
              },
            ),
            Consumer<MachineryController>(
              builder: (context, controller, child) {
                return InfoCard(
                  title: 'Rented',
                  value: controller.getRentedCount().toString(),
                  icon: Icons.agriculture,
                  bgColor: const Color(0xFF388E3C),
                );
              },
            ),
            Consumer<MachineryController>(
              builder: (context, controller, child) {
                return InfoCard(
                  title: 'Available',
                  value: controller.getAvailableCount().toString(),
                  icon: Icons.check_circle_outline,
                  bgColor: const Color(0xFF388E3C),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}