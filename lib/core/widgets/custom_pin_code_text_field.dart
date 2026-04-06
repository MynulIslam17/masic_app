import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:pinput/pinput.dart';

class CustomPinCodeTextField extends StatelessWidget {
  const CustomPinCodeTextField(
      {super.key, this.textEditingController, this.validator, this.focusNode,this.autoFocus=false});

  final TextEditingController? textEditingController;
  final FormFieldValidator? validator;
  final FocusNode? focusNode;
  final bool autoFocus;

  @override
  Widget build(BuildContext context) {
    return Pinput(
        focusNode: focusNode,

        controller: textEditingController,
        length: 6,
        separatorBuilder: (index) => SizedBox(width: 14.w),
        defaultPinTheme: PinTheme(

          width: 50.w,
          height: 50.h,
          textStyle: TextStyle(color: AppColors.darkColor, fontSize: 16.sp),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
            //shape: BoxShape.circle,
            color: AppColors.bgColor,
            borderRadius: BorderRadius.circular(8),
           // border: Border.all(color: AppColors.grayShade100),
          ),
        ),
        focusedPinTheme: PinTheme(
          width: 50.w,
          height: 50.h,
          textStyle: const TextStyle(color: AppColors.darkColor, fontSize: 20),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
            //shape: BoxShape.circle,
            color: AppColors.bgColor,
           borderRadius: BorderRadius.circular(8),
           // border: Border.all(color: AppColors.grayShade100),
          ),
        ),
        cursor: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 2.w,
              height: 20.h,
              color: AppColors.darkColor,
            ),
          ],
        ),
        keyboardType: TextInputType.number,
        //obscureText: true,
        autofocus: true,
        onChanged: (value) {},
        obscuringCharacter: '-');
  }
}
