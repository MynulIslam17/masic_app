import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:get/get.dart';

class CreateAnnouncementsScreen extends StatefulWidget {
  const CreateAnnouncementsScreen({super.key});

  @override
  State<CreateAnnouncementsScreen> createState() =>
      _CreateAnnouncementsScreenState();
}

class _CreateAnnouncementsScreenState extends State<CreateAnnouncementsScreen> {
  final TextEditingController _titleTEController = TextEditingController();
  final TextEditingController _decTEController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(title: 'Request announcements'),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Column(
          children: [
            SizedBox(height: 16.h),
            CustomTextField(
              borderColor: AppColors.colorE6E6E6,
              showShadow: false,
              filColor: AppColors.bgColor,
              controller: _titleTEController,
              hintText: 'Announcements title',
            ),

            SizedBox(height: 8.h),
            CustomButton(
              prefixIcon: Icons.cloud_upload_outlined,
              bordersColor: AppColors.colorE6E6E6,
              backgroundColor: AppColors.bgColor,
              foregroundColor: AppColors.colorB0B0B0,
              fontSize: 14.sp,
              height: 58.h,
              fontWeight: FontWeight.w400,
              radius: 16.r,
              onPressed: () {
                // PhotoPickerHelper.showPicker(
                //   context: context,
                //   onImagePicked: (file) {
                //     print(file.path);
                //   },
                // );
              },
              label: 'Upload banner',
            ),

            SizedBox(height: 16.h),

            CustomTextField(
              filColor: AppColors.bgColor,
              maxLines: 20,
              minLines: 20,
              borderColor: AppColors.colorE6E6E6,
              showShadow: false,
              controller: _decTEController,
              hintText: 'Write a description here . . .',
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: CustomButton(onPressed: () {}, label: 'Submit'),
        ),
      ),
    );
  }
}
