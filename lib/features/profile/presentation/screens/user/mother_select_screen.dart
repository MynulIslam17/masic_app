import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/empty_data_widget.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/profile/data/models/user_model.dart';
import 'package:masic_generation/features/profile/presentation/widgets/filter_dialog.dart';
import 'package:masic_generation/features/profile/presentation/widgets/member_card.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';

class MotherSelectScreen extends StatefulWidget {
  const MotherSelectScreen({super.key});

  @override
  State<MotherSelectScreen> createState() => _MotherSelectScreenState();
}

class _MotherSelectScreenState extends State<MotherSelectScreen> {
  late final String? motherId;
  late final bool isMandatory;

  @override
  void initState() {
    super.initState();
    motherId = Get.arguments as String?;
    isMandatory = motherId == null && !AuthController.to.isAdmin();
    ProfileController.to.enterMotherTreePicker(placedOnly: motherId == null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ProfileController.to.refresh(showLoader: true);
    });
  }

  @override
  void dispose() {
    ProfileController.to.stopMotherTreePicker();
    super.dispose();
  }

  Future<void> _handleBack() async {
    if (Navigator.of(context).canPop() && !isMandatory) {
      Get.back();
      return;
    }
    await AuthController.to.logout();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: CustomScaffold(
        appBar: CustomAppBar(
          title: 'Select Mother Tree',
          showLeading: true,
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
            physics: AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
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
                Obx(() {
                  final users = _displayedUsers(controller, motherId);
                  return Row(
                    children: [
                      CustomText(
                        textAlign: TextAlign.start,
                        fontSize: 12.sp,
                        text: 'Total user : ${users.length}',
                      ),
                    ],
                  );
                }),

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
                      final users = _displayedUsers(controller, motherId);
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
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Obx(() {
              return CustomButton(
                isLoading: controller.motherTreeState.isLoading,
                onPressed: () {
                  if (AuthController.to.isAdmin()) {
                    controller.addMember(motherId ?? '');
                  } else {
                    controller.motherTreeSelect();
                  }
                },
                label: 'Submit',
              );
            }),
          ),
        ),
      ),
    );
  }

  List<UserModel> _displayedUsers(
    ProfileController controller,
    String? motherId,
  ) {
    final currentId = ProfileController.to.userData?.sId;
    return controller.usersData.where((u) {
      if (u.isDeleted == true) return false;
      if (u.sId != null && u.sId == currentId) return false;
      if (_isSuperAdmin(u)) return false;
      if (motherId == null && !_isPlaced(u)) return false;
      return true;
    }).toList();
  }

  bool _isSuperAdmin(UserModel user) {
    final role = (user.role ?? '').trim().toLowerCase();
    return role == 'superadmin' || role == 'super_admin';
  }

  bool _isPlaced(UserModel user) =>
      (user.treeJoinStatus ?? '').trim().toLowerCase() == 'placed';
}

extension on Widget {
  Widget get flipped {
    return Transform.flip(flipX: true, child: this);
  }
}
