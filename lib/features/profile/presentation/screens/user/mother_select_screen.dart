import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/empty_data_widget.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/profile/presentation/widgets/filter_dialog.dart';
import 'package:masic_generation/features/profile/presentation/widgets/member_card.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';

class MotherSelectScreen extends StatelessWidget {
  const MotherSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? motherId = Get.arguments as String?;
    final controller = ProfileController.to;
    return CustomScaffold(
      appBar: CustomAppBar(
        title: 'Select mother tree',
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => FilterDialog(),
              );
            },
            icon: Assets.icons.filter.svg(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refresh(),
        child: SingleChildScrollView(
          controller: controller.scrollController,
          physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            children: [
              CustomTextField(
                validator: (_) => null,
                prefixIcon: Assets.icons.search.svg(),
                borderRadio: 100.r,
                borderColor: AppColors.colorE6E6E6,
                showShadow: false,
                controller: controller.searchController,
                hintText: 'Search here . . .',
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  CustomText(
                    textAlign: TextAlign.start,
                    fontSize: 12.sp,
                    text: 'Total user : ${controller.usersData.length}',
                  ),
                ],
              ),

              /// ============ > Events List < ============
              SizedBox(height: 24.h),
              Obx(() {
                switch (controller.loadingState) {
                  case LoadingState.initial:
                  case LoadingState.loading:
                    return SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.45,
                      child: const Center(child: CustomLoader()),
                    );

                  case LoadingState.offline:
                  case LoadingState.error:
                    return SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.45,
                      child: EmptyDataWidget(
                        message: 'Failed to load users. Please try again.',
                        onRefresh: () => controller.refresh(),
                      ),
                    );

                  case LoadingState.loaded:
                    final users = motherId == null
                        ? controller.usersData
                            .where(
                              (u) =>
                                  u.role == 'user' &&
                                  u.isDeleted != true &&
                                  u.sId != ProfileController.to.userData?.sId,
                            )
                            .toList()
                        : controller.usersData;

                    if (users.isEmpty) {
                      return SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.45,
                        child: EmptyDataWidget(
                          message: 'No user found.',
                          onRefresh: () => controller.refresh(),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return MemberCard(
                          isTree: motherId != null,
                          user: user,
                          isMotherTree: motherId == null,
                        );
                      },
                      itemCount: users.length,
                      separatorBuilder: (context, index) => SizedBox(height: 10.h),
                    );
                }
              }),
              Obx(
                () => controller.isLoadingMore
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Center(child: CustomLoader()),
                      )
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Obx(() {
              return CustomButton(
                isLoading: controller.motherTreeState.isLoading,
                onPressed: () {
                  if(AuthController.to.isAdmin()) {
                    controller.addMember(motherId ?? '');
                  }else {
                    controller.motherTreeSelect();
                  }
                },
                label: 'Submit',
              );
            }
          ),
        ),
      ),
    );
  }
}
