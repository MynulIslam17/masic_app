import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/core/widgets/empty_data_widget.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/request/presentation/controllers/request_controller.dart';
import 'package:flutter_task/features/request/presentation/widgets/request_card_widget.dart';
import 'package:flutter_task/features/request/presentation/widgets/request_simmer.dart';
import 'package:get/get.dart';

class RequestScreen extends StatelessWidget {
  const RequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = RequestController.to;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return CustomScaffold(
      paddingSide: 0,
      body: RefreshIndicator(
        edgeOffset: kToolbarHeight * 2.h,
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
              expandedHeight: 116.h,
              leading: IconButton(
                icon: isRtl
                    ? Assets.icons.backButton
                          .svg(height: 24.h, width: 24.w)
                          .flipped
                    : Assets.icons.backButton.svg(height: 24.h, width: 24.w),
                onPressed: () => Navigator.pop(context),
              ),

              title: CustomText(
                text: 'Request',
                fontSize: 16.sp,
                color: AppColors.appBarTitleColor,
              ),

              centerTitle: true,

              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 16.w,
                      right: 16.w,
                      top: kToolbarHeight,
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: CustomTextField(
                        validator: (_) => null,
                        prefixIcon: Assets.icons.search.svg(),
                        borderRadio: 100.r,
                        borderColor: AppColors.colorE6E6E6,
                        showShadow: false,
                        controller: controller.searchController,
                        hintText: 'Search here . . .',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Obx(
                          () => CustomText(
                            textAlign: TextAlign.start,
                            fontSize: 12.sp,
                            text:
                                'Total events : ${controller.requests.length}',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),

            // ── List / shimmer / error ──
            Obx(() {
              switch (controller.loadingState) {
                case LoadingState.initial:
                case LoadingState.loading:
                  return const SliverToBoxAdapter(child: RequestShimmer());
                case LoadingState.offline:
                case LoadingState.error:
                  return SliverToBoxAdapter(
                    child: EmptyDataWidget(
                      message: 'Failed to load Request. Please try again.',
                      onRefresh: () async => await controller.refresh(),
                    ),
                  );

                case LoadingState.loaded:
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding:  EdgeInsets.only(bottom: 10.h),
                        child: RequestCardWidget(
                          request: controller.requests[index],
                        ),
                      ),
                      childCount: controller.requests.length,
                    ),
                  );
              }
            }),

            // ── Load more indicator ──
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
