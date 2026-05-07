import 'package:flutter/material.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/features/home/presentation/home_screen.dart';
import 'package:flutter_task/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter_task/features/tree/tree_screen.dart';

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
      icon: Assets.icons.profileHome.path,
      screen: const ProfileScreen(),
    ),
  ];
}
