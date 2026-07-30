import 'package:flutter/material.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/features/ai_agent/ai_agent_screen.dart';
import 'package:masic_generation/features/home/presentation/home_screen.dart';
import 'package:masic_generation/features/profile/presentation/screens/user/profile_screen.dart';
import 'package:masic_generation/features/tree/presentation/screens/tree_screen.dart';
import 'package:masic_generation/features/tree/presentation/screens/admin_tree_screen.dart';
import 'package:masic_generation/features/profile/presentation/screens/admin/admin_profile_screen.dart';

class NavItemModel {
  final String icon;
  final String? activeIcon;
  final String? label;
  final Widget screen;

  const NavItemModel({
    required this.icon,
     this.activeIcon,
     this.label,
    required this.screen,
  });

  static List<NavItemModel> get userNavItems => _navItems;
  static List<NavItemModel> get adminNavItems => _adminNavItems;

  // ─── Bottom Nav Items ──────────────────────────────────────────────────────
  static final List<NavItemModel> _navItems = [
    NavItemModel(
      icon: Assets.icons.tree.path,
      screen: const TreeScreen(),
    ),
    NavItemModel(
      icon: Assets.icons.home.path,
      screen: const HomeScreen(),
    ),
    NavItemModel(
      icon: Assets.icons.ai.path,
      screen: const AiAgentScreen(),
    ),
    NavItemModel(
      icon: Assets.icons.profileHome.path,
      screen: const ProfileScreen(),
    ),
  ];

  static final List<NavItemModel> _adminNavItems = [
    NavItemModel(
      icon: Assets.icons.tree.path,
      screen: const AdminTreeScreen(),
    ),
    NavItemModel(
      icon: Assets.icons.home.path,
      screen: const HomeScreen(),
    ),
    NavItemModel(
      icon: Assets.icons.ai.path,
      screen: const AiAgentScreen(),
    ),
    NavItemModel(
      icon: Assets.icons.profileHome.path,
      screen: const AdminProfileScreen(),
    ),
  ];
}
