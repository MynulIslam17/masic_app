import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/helpers/time_format.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/notification/data/models/notification_model.dart';
import 'package:get/get.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.notification});

  final NotificationModel notification;

  bool get _isUnread => notification.isRead != true;

  String get _formattedTime {
    final createdAt = notification.createdAt;
    if (createdAt == null || createdAt.isEmpty) return '';
    try {
      return TimeFormatHelper.timeWithAMPM(DateTime.parse(createdAt).toLocal());
    } catch (_) {
      return '';
    }
  }

  String get _formattedDate {
    final createdAt = notification.createdAt;
    if (createdAt == null || createdAt.isEmpty) return '';
    return TimeFormatHelper.getDate(createdAt);
  }

  IconData get _typeIcon {
    switch (notification.type?.toLowerCase()) {
      case 'announcement':
        return Icons.campaign_outlined;
      case 'poll':
        return Icons.poll_outlined;
      case 'request':
        return Icons.description_outlined;
      case 'member':
        return Icons.family_restroom_outlined;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  void _onTap() {
    final referenceId = notification.referenceId;
    if (referenceId == null || referenceId.isEmpty) return;

    switch (notification.type?.toLowerCase()) {
      case 'announcement':
        Get.toNamed(AppRoutes.announcementsDetailsScreen, arguments: referenceId);
        break;
      case 'poll':
        Get.toNamed(AppRoutes.pollDetailsScreen, arguments: referenceId);
        break;
      case 'request':
        Get.toNamed(AppRoutes.requestDetailsScreen, arguments: referenceId);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: _onTap,
      marginBottom: 10.h,
      paddingAll: 16.r,
      radiusAll: 10.r,
      color: _isUnread ? AppColors.primaryColor100 : Colors.white,
      bordersColor: _isUnread ? AppColors.primaryColor : AppColors.colorE6E6E6,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CustomNetworkImage(
                boxShape: BoxShape.circle,
                height: 44.r,
                width: 44.r,
                imageUrl: notification.data?.profileImage,
                fallbackAsset: Assets.images.profile.image(),
              ),
              Positioned(
                right: -2.w,
                bottom: -2.h,
                child: Container(
                  height: 20.r,
                  width: 20.r,
                  decoration: BoxDecoration(
                    color: _isUnread
                        ? AppColors.primaryColor
                        : AppColors.colorB0B0B0,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Icon(
                    _typeIcon,
                    size: 11.r,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomText(
                        textAlign: TextAlign.start,
                        maxline: 1,
                        textOverflow: TextOverflow.ellipsis,
                        text: notification.title ?? 'Notification',
                        fontSize: 14.sp,
                        fontWeight: _isUnread ? FontWeight.w600 : FontWeight.w400,
                        color: _isUnread
                            ? AppColors.primaryColor
                            : AppColors.black600TextColor,
                      ),
                    ),
                    if (_formattedTime.isNotEmpty) ...[
                      SizedBox(width: 8.w),
                      CustomText(
                        textAlign: TextAlign.end,
                        text: _formattedTime,
                        fontSize: 10.sp,
                        color: AppColors.color8A8A8A,
                      ),
                    ],
                  ],
                ),
                if (notification.type != null && notification.type!.isNotEmpty)
                  CustomText(
                    top: 4.h,
                    textAlign: TextAlign.start,
                    text: notification.type!.toUpperCase(),
                    fontSize: 9.sp,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                CustomText(
                  top: 6.h,
                  textAlign: TextAlign.start,
                  maxline: 2,
                  text: notification.message ?? '',
                  fontSize: 11.sp,
                  color: AppColors.grayShade100,
                ),
                if (_formattedDate.isNotEmpty)
                  CustomText(
                    top: 8.h,
                    textAlign: TextAlign.start,
                    text: _formattedDate,
                    fontSize: 10.sp,
                    color: AppColors.color8A8A8A,
                  ),
              ],
            ),
          ),
          if (_isUnread)
            Container(
              margin: EdgeInsets.only(left: 8.w, top: 4.h),
              height: 8.r,
              width: 8.r,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
