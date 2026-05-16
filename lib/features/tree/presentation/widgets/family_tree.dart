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

  const FamilyTree({
    super.key,
    required this.root,
    required this.topChildren,
    required this.botChildren,
    this.rootTopY = 380.0,
  });

  static double _childTopFromRoot(int index, double rootTopY) {
    final int reverseIndex = index;
    return rootTopY -
        TreeController.vPad -
        (reverseIndex + 1) * TreeController.cardH -
        reverseIndex * TreeController.cardGap;
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
    final double rootLeft =
        (TreeController.totalW - TreeController.centerW) / 2;

    final String label = root.label?.isNotEmpty == true
        ? root.label!
        : (root.linkedUser?.name ?? '');

    return SizedBox(
      width: TreeController.totalW,
      height: totalH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Lines ──────────────────────────────────────────────
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
              ),
            ),
          ),

          for (int i = 0; i < topChildren.length; i++)
            _childTile(
              topChildren[i],
              top: _childTopFromRoot(
                topChildren.length - 1 - i,
                adjustedRootTopY,
              ),
            ),

          // ── Root card ──────────────────────────────────────────
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
            _childTile(
              botChildren[i],
              top: _childBotFromRoot(i, adjustedRootTopY),
            ),
        ],
      ),
    );
  }

  Widget _childTile(Children c, {required double top}) => Positioned(
    left: TreeController.childL,
    top: top,
    width: TreeController.childW,
    height: TreeController.cardH,
    child: Obx(() {
      final String label = c.label?.isNotEmpty == true
          ? c.label!
          : (c.linkedUser?.name ?? '');
      final bool hasKids = c.children?.isNotEmpty == true;
      final String key = c.sId ?? '';
      final bool exp = TreeController.to.expandedNodes[key] ?? false;

      return TreeCard(
        id: key,
        label: label,
        isRoot: false,
        hasChildren: hasKids,
        isExpanded: exp,
        onToggle: hasKids
            ? () => TreeController.to.expandedNodes[key] = !exp
            : null,
      );
    }),
  );
}
