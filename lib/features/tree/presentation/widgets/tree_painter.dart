import 'package:flutter/material.dart';
import 'package:flutter_task/features/tree/presentation/controllers/tree_controller.dart';

class TreePainter extends CustomPainter {
  final int topCount;
  final int botCount;
  final double centerMidY;
  final double botTopY;
  final Color color;
  final double? startX;

  const TreePainter({
    required this.topCount,
    required this.botCount,
    required this.centerMidY,
    required this.botTopY,
    required this.color,
    this.startX,
  });

  double _topMidY(int i) =>
      centerMidY -
          TreeController.cardH / 2 -
          TreeController.vPad -
          (topCount - 1 - i) * (TreeController.cardH + TreeController.cardGap) -
          TreeController.cardH / 2;

  double _botMidY(int i) =>
      botTopY +
          i * (TreeController.cardH + TreeController.cardGap) +
          TreeController.cardH / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final double spineX = startX ?? TreeController.spineX;
    final double childL = spineX + TreeController.stub;

    final bool hasTop = topCount > 0;
    final bool hasBot = botCount > 0;

    if (hasTop && hasBot) {
      final double spineTop = _topMidY(0);
      final double spineBot = _botMidY(botCount - 1);
      canvas.drawLine(Offset(spineX, spineTop), Offset(spineX, spineBot), p);
    } else if (hasTop && topCount == 1) {
    } else if (hasBot && botCount == 1 && !hasTop) {
    } else if (hasTop || hasBot) {
      final double spineTop = hasTop ? _topMidY(0) : centerMidY;
      final double spineBot = hasBot ? _botMidY(botCount - 1) : centerMidY;
      canvas.drawLine(Offset(spineX, spineTop), Offset(spineX, spineBot), p);
    }

    if (startX == null && (hasTop || hasBot)) {
      final double centerCardLeftEdge =
          (TreeController.totalW - TreeController.centerW) / 5;

      canvas.drawLine(
        Offset(centerCardLeftEdge, centerMidY),
        Offset(spineX, centerMidY),
        p,
      );
    }
    for (int i = 0; i < topCount; i++) {
      final double y = _topMidY(i);
      canvas.drawLine(Offset(spineX, y), Offset(childL, y), p);
    }

    for (int i = 0; i < botCount; i++) {
      final double y = _botMidY(i);
      canvas.drawLine(Offset(spineX, y), Offset(childL, y), p);
    }
  }
  @override
  bool shouldRepaint(TreePainter old) =>
      old.topCount != topCount ||
          old.botCount != botCount ||
          old.centerMidY != centerMidY ||
          old.botTopY != botTopY ||
          old.color != color ||
          old.startX != startX;
}