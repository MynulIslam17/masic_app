import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/widgets.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({super.key,  this.title,  this.subtitle, required this.onUpdate});

  final String? title;
  final String? subtitle;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      paddingHorizontal: 16.r,
      paddingVertical: 10.r,
      color: AppColors.bgColor,
      bordersColor: AppColors.borderColor,
      radiusAll: 12.r,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null && title!.isNotEmpty)
                Text(
                  title!,
                  style: TextStyle(
                      fontSize: 13.sp, fontWeight: FontWeight.w600),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(subtitle!, style: TextStyle(fontSize: 12.sp)),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onUpdate,
            icon: CustomText(text: 'Update', fontSize: 10.sp, color: AppColors.primaryColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
