import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/custom_search_field.dart';
import 'package:masic_generation/core/widgets/empty_data_widget.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/profile/data/models/user_model.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:masic_generation/features/profile/presentation/widgets/user_card.dart';
import 'package:masic_generation/features/search/model/search_model.dart';
import 'package:masic_generation/features/search/search_screen.dart';
import 'package:get/get.dart';

class AllAdminScreen extends StatelessWidget {
  const AllAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (_, __) {
        controller.setRoleFilter('', reloadIfSame: false);
      },
      child: CustomScaffold(
        paddingSide: 0,
        body: RefreshIndicator(
          edgeOffset: kToolbarHeight * 2.h,
          onRefresh: () => controller.refresh(),
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
                expandedHeight: 100.h,
                leading: IconButton(
                  icon: isRtl
                      ? Assets.icons.backButton
                            .svg(height: 24.h, width: 24.w)
                            .flipped
                      : Assets.icons.backButton.svg(height: 24.h, width: 24.w),
                  onPressed: () => Get.back(),
                ),
                title: CustomText(
                  text: 'Admin',
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
                        child: CustomSearchField(
                          readOnly: true,
                          onTap: () {
                            showSearch(
                              context: context,
                              delegate: SearchScreen(
                                onSearch: (String query) async {
                                  await controller.search.search(query);
                                  return controller.search.results
                                      .map(
                                        (a) => SearchModel(
                                          model: a,
                                          title: a.name,
                                          personName: a.name,
                                          personArabicName: a.arabicName,
                                          subtitle: a.email,
                                          image: a.profileImage,
                                        ),
                                      )
                                      .toList();
                                },
                                onResultTap: (result) {
                                  controller.search.clear();
                                  Get.toNamed(
                                    AppRoutes.profileDetailsScreen,
                                    arguments: result.model as UserModel,
                                  );
                                },
                              ),
                            );
                          },
                          searchController: controller.searchController,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      Obx(
                        () => CustomText(
                          textAlign: TextAlign.start,
                          fontSize: 12.sp,
                          text: 'Total user : ${controller.usersData.length}',
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
              Obx(() {
                switch (controller.loadingState) {
                  case LoadingState.initial:
                  case LoadingState.loading:
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CustomLoader()),
                    );
                  case LoadingState.offline:
                  case LoadingState.error:
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyDataWidget(
                        message: 'Failed to load admins. Please try again.',
                        onRefresh: () => controller.refresh(),
                      ),
                    );
                  case LoadingState.loaded:
                    if (controller.usersData.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyDataWidget(
                          message: 'No admin found.',
                          onRefresh: () => controller.refresh(),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: EdgeInsets.only(
                            bottom: 10.h,
                            left: 16.w,
                            right: 16.w,
                          ),
                          child: UserCard(user: controller.usersData[index]),
                        ),
                        childCount: controller.usersData.length,
                      ),
                    );
                }
              }),
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
      ),
    );
  }
}

extension on Widget {
  Widget get flipped {
    return Transform.flip(flipX: true, child: this);
  }
}
