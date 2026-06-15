import 'package:flutter/material.dart';
import 'package:masic_generation/core/theme/app_colors.dart';


class CustomLoader extends StatelessWidget {
  final double? top;
  final double? bottom;
  const CustomLoader({super.key, this.top, this.bottom});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.only(top: top ?? 0, bottom: bottom ?? 0),
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primaryColor,
        ),
      ),
    );
  }
}
