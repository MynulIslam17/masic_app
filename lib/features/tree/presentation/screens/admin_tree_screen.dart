import 'package:flutter/material.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/core/widgets/custom_button.dart';
import 'package:flutter_task/core/widgets/custom_loader.dart';
import 'package:flutter_task/core/widgets/custom_text.dart';
import 'package:flutter_task/core/widgets/empty_data_widget.dart';
import 'package:flutter_task/features/tree/presentation/controllers/tree_controller.dart';
import 'package:flutter_task/features/tree/presentation/widgets/family_tree.dart';
import 'package:get/get.dart';

class AdminTreeScreen extends StatelessWidget {
  const AdminTreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = TreeController.to;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: SingleChildScrollView(
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          child: Stack(
            children: [

              Assets.icons.treeHome.svg(fit: BoxFit.cover),

              SafeArea(
                child: Obx(() {
                  switch (ctrl.loadingState) {
                    case LoadingState.initial:
                    case LoadingState.loading:
                      return const Center(child: CustomLoader());
                    case LoadingState.offline:
                    case LoadingState.error:
                      return EmptyDataWidget(
                        message: 'Failed to load data. Please try again.',
                        onRefresh: () async => await ctrl.loadData(),
                      );
                    case LoadingState.loaded:
                      final treeData = ctrl.treeData;

                      if (treeData == null || treeData.root == null) {
                        return Center(child: CustomText(text: 'No data available'));
                      }
                      final root = ctrl.treeData!.root!;
                      final all = root.children ?? [];
                      final half = all.length ~/ 2;
                      return FamilyTree(
                        root: root,
                        topChildren: all.sublist(0, half),
                        botChildren: all.sublist(half),
                        onToggleEdit:  true
                      );
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
