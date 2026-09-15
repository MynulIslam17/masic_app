import 'package:flutter/material.dart';
import 'package:masic_generation/core/helpers/localized_name_helper.dart';
import 'package:masic_generation/core/widgets/custom_text.dart';
import 'package:masic_generation/features/translation/presentation/controller/translation_controller.dart';
import 'package:get/get.dart';

/// One name field: English shows [name]; Arabic shows [arabicName] or translated [name].
class LocalizedNameText extends StatelessWidget {
  const LocalizedNameText({
    super.key,
    this.name,
    this.arabicName,
    this.fallback,
    this.fontSize,
    this.fontWeight = FontWeight.w400,
    this.color,
    this.textAlign = TextAlign.center,
    this.maxline,
    this.textOverflow,
    this.left = 0,
    this.right = 0,
    this.top = 0,
    this.bottom = 0,
  });

  final String? name;
  final String? arabicName;
  final String? fallback;
  final double? fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final TextAlign textAlign;
  final int? maxline;
  final TextOverflow? textOverflow;
  final double left;
  final double right;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      TranslationController.to.currentLanguage.value;
      final text = LocalizedNameHelper.display(
        name: name,
        arabicName: arabicName,
        fallback: fallback,
      );
      final translate = LocalizedNameHelper.shouldTranslateName(
        name: name,
        arabicName: arabicName,
      );

      return CustomText(
        text: text.isNotEmpty ? text : (fallback ?? ''),
        enableAutoTranslate: translate,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        textAlign: textAlign,
        maxline: maxline,
        textOverflow: textOverflow,
        left: left,
        right: right,
        top: top,
        bottom: bottom,
      );
    });
  }
}
