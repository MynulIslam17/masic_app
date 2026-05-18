import 'package:flutter/material.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/features/tree/data/models/tree_model.dart';
import 'package:flutter_task/features/tree/presentation/controllers/tree_controller.dart';
import 'package:flutter_task/features/tree/presentation/widgets/Tree_card.dart';
import 'package:flutter_task/features/tree/presentation/widgets/tree_painter.dart';
import 'package:get/get.dart';

class FamilyTree extends StatelessWidget {
  final Root root;
  final List<Children> topChildren;
  final List<Children> botChildren;
  final double rootTopY;
  final bool onToggleEdit;
  final bool hideRoot;

  const FamilyTree({
    super.key,
    required this.root,
    required this.topChildren,
    required this.botChildren,
    this.rootTopY = 380.0,
    this.onToggleEdit = false,
    this.hideRoot = false,
  });

  static double _childTopFromRoot(int index, double rootTopY) {
    return rootTopY -
        TreeController.vPad -
        (index + 1) * TreeController.cardH -
        index * TreeController.cardGap;
  }

  static double _childBotFromRoot(int index, double rootTopY) {
    return rootTopY +
        TreeController.cardH +
        TreeController.vPad +
        index * (TreeController.cardH + TreeController.cardGap);
  }

  @override
  Widget build(BuildContext context) {
    final double topStart = topChildren.isNotEmpty
        ? _childTopFromRoot(topChildren.length - 1, rootTopY)
        : rootTopY;

    final double botEnd = botChildren.isNotEmpty
        ? _childBotFromRoot(botChildren.length - 1, rootTopY) +
              TreeController.cardH
        : rootTopY + TreeController.cardH;

    final double offsetY = topStart < 0 ? -topStart : 0;
    final double totalH = botEnd + offsetY;
    final double adjustedRootTopY = rootTopY + offsetY;

    final double spineX = hideRoot ? 0 : TreeController.spineX;
    final double childL = spineX + TreeController.stub;
    final double nestedW = childL + TreeController.childW;

    final double rootLeft =
        (TreeController.totalW - TreeController.centerW) / 1.5;

    final String label = root.label?.isNotEmpty == true
        ? root.label!
        : (root.linkedUser?.name ?? '');

    return SizedBox(
      width: hideRoot ? nestedW : TreeController.totalW,
      height: totalH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: TreePainter(
                topCount: topChildren.length,
                botCount: botChildren.length,
                centerMidY: adjustedRootTopY + TreeController.cardH / 2,
                botTopY:
                    adjustedRootTopY +
                    TreeController.cardH +
                    TreeController.vPad,
                color: AppColors.primaryColor.withOpacity(0.38),
                startX: hideRoot ? spineX : null,
              ),
            ),
          ),

          for (int i = 0; i < topChildren.length; i++)
            Positioned(
              left: childL,
              top: _childTopFromRoot(
                topChildren.length - 1 - i,
                adjustedRootTopY,
              ),
              child: Obx(() => _childContent(topChildren[i])),
            ),
          if (!hideRoot)
            Positioned(
              left: rootLeft,
              top: adjustedRootTopY,
              width: TreeController.centerW,
              height: TreeController.cardH,
              child: TreeCard(
                id: root.sId ?? '',
                label: label,
                isRoot: true,
                hasChildren: false,
                isExpanded: false,
              ),
            ),

          for (int i = 0; i < botChildren.length; i++)
            Positioned(
              left: childL,
              top: _childBotFromRoot(i, adjustedRootTopY),
              child: Obx(() => _childContent(botChildren[i])),
            ),
        ],
      ),
    );
  }

  Widget _childContent(Children c) {
    final String label = c.label?.isNotEmpty == true
        ? c.label!
        : (c.linkedUser?.name ?? '');
    final bool hasKids = c.children?.isNotEmpty == true;
    final String key = c.sId ?? '';
    final bool exp = TreeController.to.expandedNodes[key] ?? false;

    if (exp && hasKids) {
      final kids = c.children!;
      final int half = (kids.length / 2).ceil();

      final fakeRoot = Root(
        sId: c.sId,
        linkedUser: c.linkedUser,
        label: c.label,
        level: c.level,
        children: kids,
        relationType: c.relationType,
      );

      final double nestedRootTopY =
          (half) * (TreeController.cardH + TreeController.cardGap) -
          TreeController.cardGap +
          TreeController.vPad;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: TreeController.cardH,
            child: TreeCard(
              onToggleEdit: onToggleEdit
                  ? () => TreeController.to.deleteUser(c.sId ?? '')
                  : null,
              id: key,
              label: label,
              isRoot: false,
              hasChildren: hasKids,
              isExpanded: exp,
              onToggle: () => TreeController.to.expandedNodes[key] = !exp,
            ),
          ),
          FamilyTree(
            root: fakeRoot,
            topChildren: kids.sublist(0, half),
            botChildren: kids.sublist(half),
            rootTopY: nestedRootTopY,
            onToggleEdit: onToggleEdit,
            hideRoot: true,
          ),
        ],
      );
    }

    return SizedBox(
      height: TreeController.cardH,
      child: TreeCard(
        onToggleEdit: onToggleEdit
            ? () => TreeController.to.deleteUser(c.sId ?? '')
            : null,
        id: key,
        label: label,
        isRoot: false,
        hasChildren: hasKids,
        isExpanded: exp,
        onToggle: hasKids
            ? () => TreeController.to.expandedNodes[key] = !exp
            : null,
      ),
    );
  }
}
