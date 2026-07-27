// lib/features/settings/data/model/settings_menu_item.dart

import 'package:flutter/material.dart';

enum SettingsMenuItemType { profile, payment, terms, help, invite, logout }

class SettingsMenuItem {
  final String id;
  final String title;
  final IconData icon;
  final SettingsMenuItemType type;
  final bool isDestructive; // For logout button

  const SettingsMenuItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.type,
    this.isDestructive = false,
  });

  static List<SettingsMenuItem> get menuItems => [
    const SettingsMenuItem(
      id: '1',
      title: 'Edit Profile',
      icon: Icons.person_outline,
      type: SettingsMenuItemType.profile,
    ),
    const SettingsMenuItem(
      id: '2',
      title: 'Payment Option',
      icon: Icons.payment,
      type: SettingsMenuItemType.payment,
    ),
    const SettingsMenuItem(
      id: '3',
      title: 'Terms & Conditions',
      icon: Icons.description,
      type: SettingsMenuItemType.terms,
    ),
    const SettingsMenuItem(
      id: '4',
      title: 'Help Center',
      icon: Icons.help_outline,
      type: SettingsMenuItemType.help,
    ),
    const SettingsMenuItem(
      id: '5',
      title: 'Invite Friends',
      icon: Icons.share,
      type: SettingsMenuItemType.invite,
    ),
    const SettingsMenuItem(
      id: '6',
      title: 'Logout',
      icon: Icons.logout,
      type: SettingsMenuItemType.logout,
      isDestructive: true,
    ),
  ];
}
