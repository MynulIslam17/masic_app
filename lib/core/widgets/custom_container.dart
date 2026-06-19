import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer({
    super.key,
    this.child,
    this.color,
    this.linearColors,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
    this.bordersColor,
    this.border,
    this.height,
    this.width,
    this.radiusAll,
    this.borderWidth = 1.0,
    this.shape = BoxShape.rectangle,
    this.paddingHorizontal,
    this.paddingVertical,
    this.horizontalMargin,
    this.verticalMargin,
    this.alignment,
    this.onTap,
    this.marginLeft,
    this.marginRight,
    this.paddingLeft,
    this.paddingRight,
    this.boxShadow,
    this.topLeftRadius,
    this.topRightRadius,
    this.bottomLeft,
    this.bottomRight,
    this.elevation = false,
    this.paddingAll,
    this.marginAll,
    this.image,
    this.paddingTop,
    this.paddingBottom,
    this.marginTop,
    this.marginBottom, this.borderStyle, this.elevationColor,  this.stops,
  });

  final Widget? child;
  final Color? color;
  final List<Color>? linearColors;
  final Alignment begin;
  final Alignment end;
  final Alignment? alignment;
  final Color? bordersColor;
  final double borderWidth;
  final List<double>? stops;
  final BoxBorder? border;
  final BoxShape shape;
  final double? radiusAll;
  final double? paddingHorizontal;
  final double? paddingVertical;
  final double? horizontalMargin;
  final double? marginLeft;
  final double? marginTop;
  final double? marginBottom;
  final double? marginRight;
  final double? marginAll;
  final double? paddingLeft;
  final double? paddingTop;
  final double? paddingBottom;
  final double? paddingRight;
  final double? paddingAll;
  final double? verticalMargin;
  final double? height;
  final double? width;
  final double? topLeftRadius;
  final double? topRightRadius;
  final double? bottomLeft;
  final double? bottomRight;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;
  final bool elevation;
  final DecorationImage? image;
  final BorderStyle? borderStyle;
  final Color? elevationColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        padding: _buildPadding(),
        margin: _buildMargin(),
        alignment: alignment,
        decoration: BoxDecoration(
          image: image,
          boxShadow: boxShadow ??
              (elevation
                  ? [
                BoxShadow(
                  offset: const Offset(0, 4),
                  color: elevationColor ?? Colors.black.withOpacity(0.20),
                  blurRadius: 4,
                ),
              ]
                  : null),
          shape: shape,
          border: border ??
              (bordersColor != null
                  ? Border.all(
                color: bordersColor!,
                width: borderWidth,
                style: borderStyle ?? BorderStyle.solid,
              )
                  : null),
          // ✅ color must be null when gradient is used
          color: (linearColors != null && linearColors!.isNotEmpty) ? null : color,
          gradient: (linearColors != null && linearColors!.isNotEmpty)
              ? LinearGradient(
            stops: stops,
            colors: linearColors!,
            begin: begin,
            end: end,
          )
              : null,
          // ✅ borderRadius must be null for BoxShape.circle
          borderRadius: shape == BoxShape.circle
              ? null
              : (radiusAll != null)
              ? BorderRadius.circular(radiusAll!.r)
              : (topLeftRadius != null ||
              topRightRadius != null ||
              bottomLeft != null ||
              bottomRight != null)
              ? BorderRadius.only(
            topLeft: Radius.circular((topLeftRadius ?? 0).r),
            topRight: Radius.circular((topRightRadius ?? 0).r),
            bottomLeft: Radius.circular((bottomLeft ?? 0).r),
            bottomRight: Radius.circular((bottomRight ?? 0).r),
          )
              : null,
        ),
        child: child,
      ),
    );
  }

// ✅ Extracted padding logic
  EdgeInsetsGeometry? _buildPadding() {
    if (paddingAll != null) return EdgeInsets.all(paddingAll!);
    if (paddingHorizontal != null || paddingVertical != null) {
      return EdgeInsets.symmetric(
        horizontal: paddingHorizontal ?? 0,
        vertical: paddingVertical ?? 0,
      );
    }
    if (paddingLeft != null ||
        paddingRight != null ||
        paddingTop != null ||
        paddingBottom != null) {
      return EdgeInsets.only(
        left: paddingLeft ?? 0,
        right: paddingRight ?? 0,
        top: paddingTop ?? 0,
        bottom: paddingBottom ?? 0,
      );
    }
    return null;
  }

// ✅ Extracted margin logic
  EdgeInsetsGeometry? _buildMargin() {
    if (marginAll != null) return EdgeInsets.all(marginAll!);
    if (horizontalMargin != null || verticalMargin != null) {
      return EdgeInsets.symmetric(
        horizontal: horizontalMargin ?? 0,
        vertical: verticalMargin ?? 0,
      );
    }
    if (marginLeft != null ||
        marginRight != null ||
        marginTop != null ||
        marginBottom != null) {
      return EdgeInsets.only(
        left: marginLeft ?? 0,
        right: marginRight ?? 0,
        top: marginTop ?? 0,
        bottom: marginBottom ?? 0,
      );
    }
    return null;
  }
}
