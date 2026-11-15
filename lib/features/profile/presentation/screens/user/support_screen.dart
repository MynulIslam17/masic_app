import 'package:masic_generation/core/helpers/app_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';


class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: const CustomAppBar(title: 'Admin support'),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 345.h,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.images.supportBg.path),
              ),
            ),
          ),
          //  Spacer(),
          CustomContainer(
            paddingAll: 24.r,
            radiusAll: 32.r,
            bordersColor: AppColors.primaryColor,
            //linearColors: AppColors.dialogLinearColors,
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            child: Column(
              children: [
                CustomText(
                  text: 'Support',
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 20.sp,
                  bottom: 6.h,
                ),
                CustomText(
                  text: "Having trouble with the app? Our support team is available to help with technical issues, account concerns, or general questions.",
                  fontSize: 12.sp,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
          ),

          CustomContainer(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: Offset(0, 4),
              )
            ],
            paddingHorizontal: 18.w,
            bottomLeft: 16.r,
            bottomRight: 16.r,
            color: AppColors.primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final Uri url = Uri.parse('tel:+966 55 797 2888');
                    if (await launchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      AppLog.error('Profile', 'Could not launch phone dialer');
                    }
                  },
                  label: CustomText(text: '+966 55 797 2888',color: Colors.white,fontWeight: FontWeight.w600),
                  icon: Assets.icons.call.svg(),
                ),
                // TextButton.icon(
                //   onPressed: () async {
                //     final Uri emailUrl = Uri(
                //       scheme: 'mailto',
                //       path: 'bta2bigma@gmail.com',
                //       query:
                //           'subject=Support Inquiry&body=Hello, I need assistance with...',
                //     );
                //     if (await launchUrl(emailUrl)) {
                //       await launchUrl(emailUrl);
                //     } else {
                //       debugPrint('Could not launch email client');
                //     }
                //   },
                //   label: CustomText(text: 'bta2bigma@gmail.com',color: Colors.white,fontWeight: FontWeight.w600,),
                //   icon: Assets.icons.mail.svg(),
                // ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
