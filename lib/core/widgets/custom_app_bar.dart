import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/custom_text.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.titleSize = 16,
    this.centerTitle = true,
    this.titleWidget,
    this.flexibleSpace,
    this.showLeading = true,
    this.actions,
    this.backAction,
    this.leading,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.toolbarHeight,
  });

  final String? title;
  final double titleSize;
  final bool centerTitle;
  final Widget? titleWidget;
  final Widget? flexibleSpace;
  final bool showLeading;
  final Color? borderColor;
  final double? borderWidth;
  final List<Widget>? actions;
  final VoidCallback? backAction;
  final Widget? leading;
  final Color? backgroundColor;
  final double? toolbarHeight;

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return AppBar(
      toolbarHeight: toolbarHeight,
      titleSpacing: 0,
      shape: borderColor != null
          ? Border(
        bottom: BorderSide(
          color: borderColor ?? AppColors.primaryColor,
          width: borderWidth ?? 1,
        ),
      )
          : null,
      centerTitle: centerTitle,
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor ?? const Color(0xffF6F5F1),
      scrolledUnderElevation: 0,
      flexibleSpace: flexibleSpace,
      leading: leading ??
          ((showLeading && (parentRoute?.canPop ?? false))
              ? IconButton(
            icon: isRtl
                ? Assets.icons.backButton.svg(
              height: 24.h,
              width: 24.w,
            ).flipped  // RTL এ mirror করা icon
                : Assets.icons.backButton.svg(
              height: 24.h,
              width: 24.w,
            ),
            onPressed: backAction ?? () => Navigator.pop(context),
          )
              : null),
      title: title != null && title!.isNotEmpty
          ? CustomText(text:
        title!,
          fontSize: titleSize.sp,
          color: AppColors.appBarTitleColor,
        )

          : titleWidget,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight ?? 60);
}

// SVG Widget এর জন্য extension
extension on Widget {
  Widget get flipped {
    return Transform.flip(flipX: true, child: this);
  }
}