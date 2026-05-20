import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/search/model/search_model.dart';

class SearchItem extends StatelessWidget {
  const SearchItem({
    super.key,
    required this.results,
    this.borderRadius,
    this.onTap,
  });

  final List<SearchModel> results;
  final double? borderRadius;
  final void Function(String selectedItem)? onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      itemCount: results.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: Colors.grey.shade200,
        indent: 16.w,
        endIndent: 16.w,
      ),
      itemBuilder: (context, index) {
        final data = results[index];
        return GestureDetector(
          onTap: () {
            if (onTap != null && data.title != null) {
              onTap!(data.title!);
            }
          },
          child: CustomContainer(
            child: Row(
              children: [
                if (data.image != null && data.image!.isNotEmpty) ...[
                  CustomNetworkImage(
                    borderRadius: borderRadius ?? 12.r,
                    width: 40.w,
                    height: 40.h,
                    imageUrl: data.image,
                  ),
                  SizedBox(width: 12.w),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: data.title ?? '',
                        fontSize: 14.sp,
                        color: AppColors.appBarTitleColor,
                      ),
                      if (data.subtitle != null &&
                          data.subtitle!.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        CustomText(
                          text: data.subtitle!,
                          fontSize: 12.sp,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}