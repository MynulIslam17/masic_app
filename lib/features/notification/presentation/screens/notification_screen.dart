import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/empty_data_widget.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/notification/presentation/controllers/notification_controller.dart';
import 'package:masic_generation/features/notification/presentation/widgets/notification_card.dart';
import 'package:masic_generation/features/notification/presentation/widgets/notification_simmer.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = NotificationController.to;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return CustomScaffold(
      paddingSide: 0,
      body: RefreshIndicator(
        edgeOffset: kToolbarHeight,
        onRefresh: () async => await controller.refresh(),
        child: CustomScrollView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.bgColor,
              pinned: true,
              floating: false,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: isRtl
                    ? Assets.icons.backButton
                          .svg(height: 24.h, width: 24.w)
                          .flipped
                    : Assets.icons.backButton.svg(height: 24.h, width: 24.w),
                onPressed: () => Navigator.pop(context),
              ),
              title: CustomText(
                text: 'Notifications',
                fontSize: 16.sp,
                color: AppColors.appBarTitleColor,
              ),
              centerTitle: true,
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              sliver: SliverToBoxAdapter(
                child: Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: CustomText(
                          textAlign: TextAlign.start,
                          fontSize: 12.sp,
                          text:
                              'Total notifications : ${controller.notifications.length}',
                        ),
                      ),
                      if (controller.unreadCount > 0)
                        CustomContainer(
                          paddingHorizontal: 10.w,
                          paddingVertical: 6.h,
                          radiusAll: 100.r,
                          color: AppColors.primaryColor100,
                          bordersColor: AppColors.primaryColor,
                          child: CustomText(
                            text: '${controller.unreadCount} unread',
                            fontSize: 10.sp,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              sliver: Obx(() {
                switch (controller.loadingState) {
                  case LoadingState.initial:
                  case LoadingState.loading:
                    return const SliverToBoxAdapter(child: NotificationShimmer());
                  case LoadingState.offline:
                  case LoadingState.error:
                    return SliverToBoxAdapter(
                      child: EmptyDataWidget(
                        message:
                            'Failed to load notifications. Please try again.',
                        onRefresh: () async => await controller.refresh(),
                      ),
                    );
                  case LoadingState.loaded:
                    if (controller.notifications.isEmpty) {
                      return SliverToBoxAdapter(
                        child: EmptyDataWidget(
                          message: 'No notifications yet.',
                          onRefresh: () async => await controller.refresh(),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => NotificationCard(
                          notification: controller.notifications[index],
                        ),
                        childCount: controller.notifications.length,
                      ),
                    );
                }
              }),
            ),
            Obx(
              () => SliverToBoxAdapter(
                child: controller.isLoadingMore
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: const Center(child: CustomLoader()),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 16.h)),
          ],
        ),
      ),
    );
  }
}

extension on Widget {
  Widget get flipped {
    return Transform.flip(flipX: true, child: this);
  }
}
