import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/auth/presentation/controller/auth_controller.dart';
import 'package:flutter_task/features/request/presentation/controllers/request_controller.dart';
import 'package:get/get.dart';

class DetailsBottomNav extends StatelessWidget {
  const DetailsBottomNav({
    super.key,
    required this.requestId,
  });

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
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomButton(
                    bordersColor: AppColors.errorColor,
                    foregroundColor: AppColors.errorColor,
                    backgroundColor: AppColors.bgColor,
                    label: 'Rejected',
                    onPressed: () {
                      Get.toNamed(
                        AppRoutes.reasonScreen,
                        arguments: requestId,
                      );
                    },
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
