import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/core/widgets/custom_search_field.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/profile/data/models/user_model.dart';
import 'package:flutter_task/features/profile/presentation/controllers/profile_controller.dart';
import 'package:flutter_task/features/profile/presentation/widgets/user_card.dart';
import 'package:flutter_task/features/search/model/search_model.dart';
import 'package:flutter_task/features/search/search_screen.dart';
import 'package:get/get.dart';

class AllAdminScreen extends StatefulWidget {
  const AllAdminScreen({super.key});

  @override
  State<AllAdminScreen> createState() => _AllAdminScreenState();
}

class _AllAdminScreenState extends State<AllAdminScreen> {


  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (_,didPop) {
        controller.setRoleFilter('');
      },
      child: CustomScaffold(
        appBar: CustomAppBar(
          backAction: (){
            controller.setRoleFilter('');
            Get.back(canPop: true);
          },
          title: 'Admin',
        ),
        body: RefreshIndicator(
          onRefresh: () => controller.refresh(),
          child: SingleChildScrollView(
            controller: controller.scrollController,
            physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Column(
              children: [
                CustomSearchField(
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

                SizedBox(height: 10.h),
                Row(
                  children: [
                    Obx(() {
                        return CustomText(
                          textAlign: TextAlign.start,
                          fontSize: 12.sp,
                          text: 'Total user : ${controller.usersData.length}',
                        );
                      }
                    ),
                  ],
                ),

                /// ============ > Events List < ============
                SizedBox(height: 24.h),
                Obx(() {
                  switch (controller.loadingState) {
                    case LoadingState.initial:
                    case LoadingState.loading:
                      return Center(child: CustomLoader());

                    case LoadingState.offline:
                    case LoadingState.error:
                      return CustomText(text: '');

                    case LoadingState.loaded:
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: controller.usersData.length,
                        itemBuilder: (context, index) {
                          final user = controller.usersData[index];
                          return UserCard(user: user);
                        },
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 10.h),
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
      ),
    );
  }
}
