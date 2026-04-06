import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:get/get.dart';


class AddCvScreen extends StatefulWidget {
  const AddCvScreen({super.key});

  @override
  State<AddCvScreen> createState() => _AddCvScreenState();
}

class _AddCvScreenState extends State<AddCvScreen> {





  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(title: "Upload documents"),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.r),
        child: CustomButton(
          label: "Save",
          onPressed: () {
            // TODO: call update API
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 24.h),

            CustomContainer(
              onTap: (){
                // PhotoPickerHelper.showPicker(
                //   context: context,
                //   onImagePicked: (image) {},
                // );
              },
              radiusAll: 12.r,
              bordersColor: AppColors.colorE8E8E8,
              paddingAll: 44.r,
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Assets.icons.uploadImage.svg(),
                  CustomText(text: "Upload CV", top: 16.h),
                ],
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
