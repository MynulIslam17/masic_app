import 'package:flutter/material.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';

class FamilyTreeBackground extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const FamilyTreeBackground({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Assets.icons.treeHome.svg(fit: BoxFit.contain),
    );
  }
}
