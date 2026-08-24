import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/constants/app_constants.dart';
import 'package:masic_generation/core/services/translation_service.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:get/get.dart';


class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool? isObscureText;
  final String? obscure;
  final Color? filColor;
  final Color? borderColor;
  final Color? hintextColor;
  final Color? labelColor;
  final Widget? prefixIcon;
  final String? labelText;
  final String? hintText;
  final double? contentPaddingHorizontal;
  final double? contentPaddingVertical;
  final double? hintextSize;
  final Widget? suffixIcon;
  final FormFieldValidator? validator;
  final bool isPassword;
  final bool? isEmail;
  final bool? readOnly;
  final double? borderRadio;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final Color? cursorColor;
  final int? maxLength;
  final int? maxLines;
  final bool? enabled;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool isDatePicker;
  final String? fontFamily;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatter;
  final int? minLines;
  final bool showShadow;
  final ValueChanged<String>? onFieldSubmitted;
  final bool isAlwaysRtl;

  const CustomTextField({
    super.key,
    this.contentPaddingHorizontal,
    this.contentPaddingVertical,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.hintextColor,
    this.borderColor,
    this.isEmail = false,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.isObscureText = false,
    this.obscure = '*',
    this.filColor,
    this.hintextSize,
    this.labelText,
    this.isPassword = false,
    this.readOnly = false,
    this.borderRadio = 16,
    this.onTap,
    this.onChanged,
    this.cursorColor,
    this.maxLength,
    this.enabled,
    this.focusNode,
    this.autofocus = false,
    this.isDatePicker = false,
    this.fontFamily,
    this.textInputAction,
    this.inputFormatter,
    this.minLines,
    this.maxLines,
    this.showShadow = true,
    this.onFieldSubmitted, this.labelColor,
    this.isAlwaysRtl = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  // ✅ Field key — language change হলে re-validate করতে ব্যবহার হবে
  final _fieldKey = GlobalKey<FormFieldState>();

  final RxString _currentLang = (Get.locale?.languageCode ?? 'en').obs;
  final RxString _translatedHint = ''.obs;
  final RxString _pleaseEnterText = ''.obs;
  final RxString _passwordMinText = 'Password: 6 characters min!'.obs;
  final RxString _checkEmailText = 'Please check your email!'.obs;

  late final Worker _localeWorker;

  @override
  void initState() {
    super.initState();
    _localeWorker = ever(_currentLang, (_) => _translateTexts());
    _translateTexts();
  }

  void _syncLocale() {
    final lang = Get.locale?.languageCode ?? 'en';
    if (_currentLang.value != lang) {
      _currentLang.value = lang;
    }
  }

  // ✅ Cache নেই — প্রতিবার সরাসরি translate করে
  Future<String> _translate(String text) async {
    if (_currentLang.value == 'en') return text;
    return await TranslationService().translate(text, targetCode: _currentLang.value);
  }

  Future<void> _translateTexts() async {
    if (!mounted) return;
    final hint = widget.hintText;
    final pleasePrefix = hint != null ? 'Please ${hint.toLowerCase()}' : '';

    final results = await Future.wait([
      hint != null ? _translate(hint) : Future.value(''),
      pleasePrefix.isNotEmpty ? _translate(pleasePrefix) : Future.value(''),
      _translate('Password: 6 characters min!'),
      _translate('Please check your email!'),
    ]);

    if (!mounted) return;
    _translatedHint.value = results[0];
    _pleaseEnterText.value = results[1];
    _passwordMinText.value = results[2];
    _checkEmailText.value = results[3];

    // ✅ Translation শেষে error message টা নতুন ভাষায় re-validate করবে
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fieldKey.currentState?.validate();
    });
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hintText != widget.hintText ||
        oldWidget.labelText != widget.labelText) {
      _translateTexts();
    }
  }

  @override
  void dispose() {
    _localeWorker.dispose();
    _currentLang.close();
    _translatedHint.close();
    _pleaseEnterText.close();
    _passwordMinText.close();
    _checkEmailText.close();
    super.dispose();
  }

  void _toggle() => setState(() => _obscureText = !_obscureText);

  String? _defaultValidator(String? value) {
    if (widget.isEmail == false) {
      if (value!.isEmpty) return _pleaseEnterText.value;
      if (widget.isPassword && value.length < 6) return _passwordMinText.value;
    } else {
      if (value!.isEmpty) return _pleaseEnterText.value;
      if (!AppConstants.emailValidate.hasMatch(value)) return _checkEmailText.value;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    _syncLocale();

    return Obx(() {
      final isLangRtl = _currentLang.value == 'ar';
      final isRtl = widget.isAlwaysRtl || isLangRtl;
      final textDir = isRtl ? TextDirection.rtl : TextDirection.ltr;
      final hintText = _translatedHint.value.isNotEmpty
          ? _translatedHint.value
          : widget.hintText;

      Widget child = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.labelText != null)
            CustomText(
              color: widget.labelColor,
              left: 6.r,
              text: widget.labelText ?? '',
              bottom: 6.h,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),

          widget.isAlwaysRtl
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(widget.borderRadio ?? 10.r),
                    boxShadow: widget.showShadow
                        ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ]
                        : [],
                  ),
                  child: TextFormField(
                    textDirection: textDir,
                    textAlign: TextAlign.right,
                    onFieldSubmitted: widget.onFieldSubmitted,
                    autofocus: widget.autofocus,
                    enabled: widget.enabled,
                    maxLength: widget.maxLength,
                    onChanged: widget.onChanged,
                    onTap: widget.isDatePicker ? null : widget.onTap,
                    readOnly: widget.readOnly ?? false,
                    controller: widget.controller,
                    keyboardType: widget.keyboardType,
                    inputFormatters: widget.inputFormatter,
                    textInputAction: widget.textInputAction,
                    obscuringCharacter: widget.obscure!,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    minLines: widget.isPassword ? 1 : (widget.minLines ?? 1),
                    maxLines: widget.isPassword ? 1 : (widget.maxLines ?? 8),
                    contextMenuBuilder: (context, editableTextState) {
                      if (widget.readOnly == true) return const SizedBox.shrink();
                      return AdaptiveTextSelectionToolbar.editableText(
                        editableTextState: editableTextState,
                      );
                    },
                    validator: widget.validator ?? _defaultValidator,
                    cursorColor: widget.cursorColor ?? AppColors.colorB0B0B0,
                    obscureText: widget.isPassword ? _obscureText : false,
                    style: TextStyle(
                      color: widget.hintextColor ?? AppColors.colorB0B0B0,
                      fontSize: widget.hintextSize ?? 12.h,
                      fontFamily: widget.fontFamily,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: widget.contentPaddingHorizontal ?? 20.w,
                        vertical: widget.contentPaddingVertical ?? 14.h,
                      ),
                      fillColor: widget.filColor ?? Colors.transparent,
                      filled: widget.filColor == null ? false : true,
                      // LTR context: icon as suffixIcon (right)
                      // RTL context: icon as prefixIcon (right in RTL)
                      prefixIcon: isLangRtl && widget.prefixIcon != null
                          ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: widget.prefixIcon,
                      )
                          : null,
                      suffixIcon: !isLangRtl && widget.prefixIcon != null
                          ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: widget.prefixIcon,
                      )
                          : null,
                      prefixIconConstraints:
                      BoxConstraints(minHeight: 24.w, minWidth: 24.w),
                      suffixIconConstraints: BoxConstraints(minHeight: 24.w, minWidth: 24.w),
                      hintText: hintText,
                      hintStyle: TextStyle(
                        color: widget.hintextColor ?? AppColors.colorB0B0B0,
                        fontSize: widget.hintextSize ?? 12.h,
                        fontWeight: FontWeight.w400,
                      ),
                      errorStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 12.h,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                      focusedBorder: _focusedBorder(),
                      enabledBorder: _enabledBorder(),
                      errorBorder: _errorBorder(),
                      border: _focusedBorder(),
                      focusedErrorBorder: _errorBorder(),
                    ),
                  ),
                )
              : DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(widget.borderRadio ?? 10.r),
              boxShadow: widget.showShadow
                  ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ]
                  : [],
            ),
            child: TextFormField(
              textDirection: textDir,
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
              onFieldSubmitted: widget.onFieldSubmitted,
              autofocus: widget.autofocus,
              enabled: widget.enabled,
              maxLength: widget.maxLength,
              onChanged: widget.onChanged,
              onTap: widget.isDatePicker ? null : widget.onTap,
              readOnly: widget.readOnly ?? false,
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatter,
              textInputAction: widget.textInputAction,
              obscuringCharacter: widget.obscure!,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              minLines: widget.isPassword ? 1 : (widget.minLines ?? 1),
              maxLines: widget.isPassword ? 1 : (widget.maxLines ?? 8),
              contextMenuBuilder: (context, editableTextState) {
                if (widget.readOnly == true) return const SizedBox.shrink();
                return AdaptiveTextSelectionToolbar.editableText(
                  editableTextState: editableTextState,
                );
              },
              validator: widget.validator ?? _defaultValidator,
              cursorColor: widget.cursorColor ?? AppColors.colorB0B0B0,
              obscureText: widget.isPassword ? _obscureText : false,
              style: TextStyle(
                color: widget.hintextColor ?? AppColors.colorB0B0B0,
                fontSize: widget.hintextSize ?? 12.h,
                fontFamily: widget.fontFamily,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: widget.contentPaddingHorizontal ?? 20.w,
                  vertical: widget.contentPaddingVertical ?? 14.h,
                ),
                fillColor: widget.filColor ?? Colors.transparent,
                filled: widget.filColor == null ? false : true,
                prefixIcon: widget.prefixIcon != null
                    ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: widget.prefixIcon,
                )
                    : null,
                suffixIcon: widget.isPassword
                    ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _toggle,
                  child: _buildSuffixIcon(_obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                )
                    : widget.suffixIcon != null ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: widget.suffixIcon,
                ) : null,
                prefixIconConstraints:
                BoxConstraints(minHeight: 24.w, minWidth: 24.w),
                suffixIconConstraints: BoxConstraints(minHeight: 24.w, minWidth: 24.w),
                hintText: hintText,
                hintStyle: TextStyle(
                  color: widget.hintextColor ?? AppColors.colorB0B0B0,
                  fontSize: widget.hintextSize ?? 12.h,
                  fontWeight: FontWeight.w400,
                ),
                errorStyle: TextStyle(
                  color: Colors.red,
                  fontSize: 12.h,
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
                focusedBorder: _focusedBorder(),
                enabledBorder: _enabledBorder(),
                errorBorder: _errorBorder(),
                border: _focusedBorder(),
                focusedErrorBorder: _errorBorder(),
              ),
            ),
          ),

          SizedBox(height: 6.h),
        ],
      );

      return child;
    });
  }

  Padding _buildSuffixIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Icon(icon, color: AppColors.colorB0B0B0),
    );
  }

  OutlineInputBorder _focusedBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(widget.borderRadio?.r ?? 16.r),
    borderSide: BorderSide(
      width: 1,
      color: widget.borderColor ?? Colors.transparent,
    ),
  );

  OutlineInputBorder _enabledBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(widget.borderRadio?.r ?? 16.r),
    borderSide: BorderSide(
      width: 1,
      color: widget.borderColor ?? Colors.transparent,
    ),
  );

  OutlineInputBorder _errorBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(widget.borderRadio?.r ?? 16.r),
    borderSide: BorderSide(
      color: widget.borderColor ?? Colors.red,
      width: 1,
    ),
  );
}