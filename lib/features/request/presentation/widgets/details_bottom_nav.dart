import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/request/presentation/controllers/request_controller.dart';
import 'package:get/get.dart';

class DetailsBottomNav extends StatelessWidget {
  const DetailsBottomNav({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context) {
    final controller = RequestController.to;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Obx(() {
          final request = controller.requests.firstWhereOrNull(
            (e) => e.sId == requestId,
          );
          if (request == null) return const SizedBox.shrink();
          final status = request.status ?? '';
          final isAdmin = AuthController.to.isAdmin();
          if (isAdmin && status == 'pending') {
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => Obx(() {
                          return CustomDialog(
                            title: "Approve Request",
                            titleColor: AppColors.primaryColor,
                            rightButtonLabel: 'Yes, Approve',
                            rightButtonBgColor: AppColors.primaryColor,
                            rightButtonLabelColor: Colors.white,
                            onTapLeftButton: () => Get.back(),
                            isLoading: controller.updateState.isLoading,
                            onTapRightButton: () => controller.updateStatus(
                              requestId: requestId,
                              status: 'approved',
                            ),
                            description:
                                'Are you sure want to approve your Request?',
                          );
                        }),
                      );
                    },
                    label: 'Approved',
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  flex: 3,
                  child: CustomButton(
                    bordersColor: AppColors.primaryColor,
                    foregroundColor: AppColors.primaryColor,
                    backgroundColor: AppColors.bgColor,
                    label: 'Additional info need',
                    onPressed: () {
                      Get.toNamed(AppRoutes.reasonScreen, arguments: {
                        'requestId': requestId,
                        'reason': 'Write additional info',
                      });
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Get.toNamed(AppRoutes.reasonScreen, arguments: {
                        'requestId': requestId,
                        'reason': 'Write decline reason',
                      });
                    },
                    child: Assets.icons.remove.svg(height: 50.r, width: 50.r),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
      ),
    );
  }
}
