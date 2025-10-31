import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/machinery_controller.dart';
import 'machinery_card.dart';

class MachineryList extends StatelessWidget {
  const MachineryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MachineryController>(
      builder: (context, machineryController, child) {
        if (machineryController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (machineryController.machinery.isEmpty) {
          return const Center(child: Text('No machinery found.'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: machineryController.machinery.length,
          itemBuilder: (context, index) {
            final doc = machineryController.machinery[index];
            final data = doc.data() as Map<String, dynamic>;
            return MachineryCard(data: data);
          },
        );
      },
    );
  }
}