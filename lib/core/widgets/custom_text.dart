import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/fonts.gen.dart';
import 'package:masic_generation/features/translation/presentation/widget/auto_translate.dart';

class CustomText extends StatelessWidget {
  const CustomText(
      {super.key,
        this.maxline,
        this.textOverflow,
        this.fontName,
        this.textAlign = TextAlign.center,
        this.left = 0,
        this.right = 0,
        this.top = 0,
        this.bottom = 0,
        this.fontSize,
        this.textHeight,
        this.fontWeight = FontWeight.w400,
        this.color,
        required this.text,
        this.decorationColor,
        this.decoration,
        this.textDirection,
        this.enableAutoTranslate = true});

  final double left;
  final TextOverflow? textOverflow;
  final double right;
  final double top;
  final double bottom;
  final double? fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final Color? decorationColor;
  final String text;
  final TextAlign textAlign;
  final int? maxline;
  final String? fontName;
  final double? textHeight;
  final TextDecoration? decoration;
  final TextDirection? textDirection;
  final bool enableAutoTranslate;



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: left, right: right, top: top, bottom: bottom),
      child: AutoTranslate(
        enable: enableAutoTranslate,
        child: Text(
          text,
          textDirection: textDirection,
          textAlign: textAlign,
          maxLines: maxline,
          overflow: textOverflow,
          style: TextStyle(
            decoration: decoration,
            decorationColor: decorationColor,
            fontSize: fontSize ?? 14.sp,
            fontFamily: fontName ?? FontFamily.poppins,
            fontWeight: fontWeight,
            color: color ?? AppColors.darkColor,
          ),
        ),
      ),
    );
  }
}