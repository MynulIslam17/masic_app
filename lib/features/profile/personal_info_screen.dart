import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:get/get.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  String? bio;
  Map<String, String>? contact;
  List<Map<String, String>> educations = [];
  List<Map<String, String>> jobs = [];
  String? cvFileName;
  String? certFileName;

  Widget _itemCard({
    required String title,
    required String subtitle,
    required VoidCallback onDelete,
    required VoidCallback onUpdate,
  }) =>
      CustomContainer(
        paddingAll: 16.r,
        color: AppColors.bgColor,
        bordersColor: AppColors.borderColor,
        radiusAll: 12.r,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 13.sp, fontWeight: FontWeight.w600),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(subtitle, style: TextStyle(fontSize: 12.sp)),
                  ],
                ],
              ),
            ),
            IconButton(
              onPressed: onUpdate,
              icon: Icon(
                Icons.edit_rounded,
                size: 18.r,
                color: AppColors.primaryColor,
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_rounded,
                size: 18.r,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      );

  Widget _addOutlineButton({
    required String label,
    required VoidCallback onPressed,
  }) =>
      CustomButton(
        onPressed: onPressed,
        label: label,
        bordersColor: AppColors.primaryColor,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primaryColor,
        suffixIcon: Icon(
          Icons.add_rounded,
          color: AppColors.primaryColor,
          size: 20.r,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      paddingSide: 24.w,
      appBar: CustomAppBar(title: 'Personal information'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Short Bio ──────────────────────────────────────────
            CustomText(text: 'Short Bio', bottom: 10.h, top: 10.h),
            if (bio != null)
              _itemCard(
                title: bio!,
                subtitle: '',
                onDelete: () => setState(() => bio = null),
                onUpdate: () {},
              )
            else
              _addOutlineButton(
                label: 'Add bio',
                onPressed: () {
                 // Get.toNamed(AppRoutes.addBioScreen);
                },
              ),

            // ── Contact Information ────────────────────────────────
            CustomText(text: 'Contact information', bottom: 10.h, top: 10.h),
            if (contact != null)
              _itemCard(
                title: contact!['phone'] ?? '',
                subtitle: contact!['email'] ?? '',
                onDelete: () => setState(() => contact = null),
                onUpdate: () {},
              )
            else
              _addOutlineButton(
                label: 'Add contact information',
                onPressed: () {
                //  Get.toNamed(AppRoutes.addContactScreen);
                },
              ),

            // ── Education ──────────────────────────────────────────
            CustomText(text: 'Education', bottom: 10.h, top: 10.h),
            if(educations.isNotEmpty)
            ...educations.asMap().entries.map(
                  (e) => _itemCard(
                title: e.value['degree'] ?? '',
                subtitle: e.value['school'] ?? '',
                onDelete: () =>
                    setState(() => educations.removeAt(e.key)),
                onUpdate: () {},
              ),
            )else
            _addOutlineButton(
              label: 'Add education',
              onPressed: () {
               // Get.toNamed(AppRoutes.addEducationScreen);
              },
            ),

            // ── Job Experience ─────────────────────────────────────
            CustomText(text: 'Job experience', bottom: 10.h, top: 10.h),
            ...jobs.asMap().entries.map(
                  (e) => _itemCard(
                title: e.value['title'] ?? '',
                subtitle: e.value['company'] ?? '',
                onDelete: () => setState(() => jobs.removeAt(e.key)),
                onUpdate: () {},
              ),
            ),
            _addOutlineButton(
              label: 'Add job experience',
              onPressed: () {
                //Get.toNamed(AppRoutes.addJobScreen);
              },
            ),

            // ── CV ─────────────────────────────────────────────────
            CustomText(text: 'CV', bottom: 10.h, top: 10.h),
            if (cvFileName != null)
              _itemCard(
                title: cvFileName!,
                subtitle: '',
                onDelete: () => setState(() => cvFileName = null),
                onUpdate: () {},
              )
            else
              _addOutlineButton(
                label: 'Upload CV',
                onPressed: () {
                //  Get.toNamed(AppRoutes.addCvScreen);
                },
              ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}