// lib/features/settings/presentation/widgets/settings_menu_item_tile.dart

import 'package:flutter/material.dart';
import 'package:Edvance/features/settings/data/model/settings_menu_item_model.dart';


class SettingsMenuItemTile extends StatelessWidget {
  final SettingsMenuItem item;
  final VoidCallback onTap;

  const SettingsMenuItemTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
        ),
        child: Row(
          children: [
            // Icon
            Icon(item.icon, color: item.isDestructive ? Colors.red : Colors.black87, size: 22),
            const SizedBox(width: 12),
            // Title
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: item.isDestructive ? Colors.red : Colors.black87,
                ),
              ),
            ),
            // Chevron
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }
}
