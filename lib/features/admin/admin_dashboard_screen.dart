import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/core/widgets/widgets.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(
        titleWidget: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              CustomNetworkImage(
                boxShape: BoxShape.circle,
                height: 42.r,
                width: 42.r,
                imageUrl: '',
                fallbackAsset: Assets.images.profile.path,
                colorFilter: ColorFilter.mode(
                  AppColors.color8A8A8A,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      enableAutoTranslate: false,
                      fontSize: 14.sp,
                      textAlign: TextAlign.start,
                      text: 'Refan',
                    ),
                    CustomText(
                      textAlign: TextAlign.start,
                      text: 'welcome to MASIC generation',
                      fontSize: 10.sp,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),


        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.menu,color: AppColors.color8A8A8A,))
        ],
      ),

    );
  }
}
