import 'package:flutter/material.dart';

class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final Function(String) onRoleChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final roles = ['Seller', 'Buyer', 'Labourer'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: roles.map((role) {
        final isSelected = selectedRole == role;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onRoleChanged(role),
              child: Card(
                elevation: isSelected ? 4 : 2,
                color: isSelected ? const Color(0xFF3A6B2E) : const Color(0xFFE8F5E8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF3A6B2E) : const Color(0xFFCCCCCC),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Text(
                    role,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF3A6B2E),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
