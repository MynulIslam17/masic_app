import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/search/model/search_model.dart';

class SearchItem extends StatelessWidget {
  const SearchItem({
    super.key,
    required this.results,
    this.borderRadius,
    this.onTap,
  });

  final List<SearchModel> results;
  final double? borderRadius;
  final void Function(SearchModel selectedItem)? onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
      itemCount: results.length,
      separatorBuilder: (_, __) => Divider(
        height: 24.h,
        color: Colors.grey.shade200,
        indent: 16.w,
        endIndent: 16.w,
      ),
      itemBuilder: (context, index) {
        final data = results[index];
        return GestureDetector(
          onTap: () {
            if (onTap != null) {
              onTap!(data);
            }
          },
          child: CustomContainer(
            child: Row(
              children: [
                if (data.image != null) ...[
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
                          textAlign: TextAlign.start,
                          textOverflow: TextOverflow.ellipsis,
                          maxline: 1,
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