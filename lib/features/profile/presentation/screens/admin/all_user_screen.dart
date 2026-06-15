import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/custom_search_field.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/profile/data/models/user_model.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:masic_generation/features/profile/presentation/widgets/filter_dialog.dart';
import 'package:masic_generation/features/profile/presentation/widgets/user_card.dart';
import 'package:masic_generation/features/search/model/search_model.dart';
import 'package:masic_generation/features/search/search_screen.dart';
import 'package:get/get.dart';

class AllUserScreen extends StatelessWidget {
  const AllUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;
    return CustomScaffold(
      appBar: CustomAppBar(
        title: 'Users',
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
                            image: a.profileImage ?? '',
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
                    if (controller.usersData.isEmpty){
                      return Center(child: CustomText(text: 'No Data Found'));
                    }
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
    );
  }
}
