import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/custom_search_field.dart';
import 'package:masic_generation/core/widgets/empty_data_widget.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/announcement/data/models/announcement_model.dart';
import 'package:masic_generation/features/announcement/presentation/controllers/announcement_controller.dart';
import 'package:masic_generation/features/announcement/presentation/widgets/announcement_card.dart';
import 'package:masic_generation/features/announcement/presentation/widgets/announcement_simmer.dart';
import 'package:masic_generation/features/announcement/presentation/widgets/tap_bar.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:masic_generation/features/search/model/search_model.dart';
import 'package:masic_generation/features/search/search_screen.dart';
import 'package:get/get.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AnnouncementController.to;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return CustomScaffold(
      paddingSide: 0,
      body: RefreshIndicator(
        edgeOffset: kToolbarHeight * 3.h,
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
              expandedHeight: AuthController.to.isAdmin() ? 150.h : 116.h,

              leading: IconButton(
                icon: isRtl
                    ? Assets.icons.backButton
                          .svg(height: 24.h, width: 24.w)
                          .flipped
                    : Assets.icons.backButton.svg(height: 24.h, width: 24.w),
                onPressed: () => Navigator.pop(context),
              ),

              title: CustomText(
                text: 'Announcements',
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
                                        title: a.title,
                                        subtitle: a.description,
                                        image: a.bannerUrl,
                                      ),
                                    )
                                    .toList();
                              },
                              onResultTap: (result) {
                                controller.search.clear();
                                Get.toNamed(
                                  AppRoutes.announcementsDetailsScreen,
                                  arguments: result.model.sId as String,
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

              bottom: AuthController.to.isAdmin()
                  ? PreferredSize(
                      preferredSize: Size.fromHeight(26.h),
                      child: Row(
                        children: [
                          TabItem(
                            label: 'Requested announce',
                            index: 0,
                            selectedTab: controller.selectedTab,
                            onTap: controller.onTabChanged,
                          ),
                          TabItem(
                            label: 'My announce',
                            index: 1,
                            selectedTab: controller.selectedTab,
                            onTap: controller.onTabChanged,
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => CustomText(
                              textAlign: TextAlign.start,
                              fontSize: 12.sp,
                              text:
                                  'Total events : ${controller.announcements.length}',
                            ),
                          ),
                        ),
                        CustomButton(
                          height: 38.h,
                          elevation: true,
                          borderWidth: 3,
                          bordersColor: const Color(0xffB0B0B0),
                          foregroundColor: AppColors.primaryColor,
                          backgroundColor: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          width: 174.w,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => CustomDialog(
                                title: "Select announcement type",
                                rightButtonLabel: 'For all',
                                leftButtonLabel: 'Group',
                                leftButtonBgColor: AppColors.primaryColor,
                                leftButtonLabelColor: Colors.white,
                                rightButtonLabelColor: AppColors.primaryColor,
                                titleColor: AppColors.primaryColor,
                                onTapLeftButton: () {
                                  Get.back();
                                  Get.toNamed(AppRoutes.memberSelectScreen);
                                },
                                onTapRightButton: () {
                                  Get.back();
                                  ProfileController.to.selectedUserIds.clear();
                                  Get.toNamed(
                                    AppRoutes.createAnnouncementsScreen,
                                  );
                                },
                                description:
                                    'Please select one which type of announcement you want to upload',
                              ),
                            );
                          },
                          label: 'Create announcements',
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
                  return const SliverToBoxAdapter(child: AnnouncementShimmer());
                case LoadingState.offline:
                case LoadingState.error:
                  return SliverToBoxAdapter(
                    child: EmptyDataWidget(
                      message:
                          'Failed to load announcements. Please try again.',
                      onRefresh: () async => await controller.refresh(),
                    ),
                  );

                case LoadingState.loaded:
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: AnnouncementCard(
                          announcement: controller.announcements[index],
                        ),
                      ),
                      childCount: controller.announcements.length,
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
