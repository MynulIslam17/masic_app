import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/helpers/helper_data.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:get/get.dart';

class MemberSelectScreen extends StatefulWidget {
  const MemberSelectScreen({super.key});

  @override
  State<MemberSelectScreen> createState() => _MemberSelectScreenState();
}

class _MemberSelectScreenState extends State<MemberSelectScreen> {
  final TextEditingController _announcementTEController = TextEditingController();

  bool isSelect = false;


  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(title: 'Select for announcement'),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Column(
          children: [
            CustomTextField(
              validator: (_) => null,
              prefixIcon: Assets.icons.search.svg(),
              borderRadio: 100.r,
              borderColor: AppColors.colorE6E6E6,
              showShadow: false,
              controller: _announcementTEController,
              hintText: 'Search here . . .',
            ),

            SizedBox(height: 10.h),
            Row(
              children: [
                CustomText(
                  textAlign: TextAlign.start,
                  fontSize: 12.sp,
                  text: 'Total user : 02',
                ),
              ],
            ),

            /// ============ > Events List < ============
            SizedBox(height: 24.h),
            ListView.builder(
              itemCount: HelperData.member.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item = HelperData.member[index];
                return _buildMemberCard(
                  imageUrl: item['imageUrl'],
                  title: item['title'],
                  description: item['description'],
                  isSelect: item['select'],
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: CustomButton(onPressed: () {
          //  Get.toNamed(AppRoutes.createAnnouncementsScreen);
          }, label: 'Submit'),
        ),
      ),

    );
  }

  Widget _buildMemberCard({
    String? imageUrl,
    String? title,
    String? description,
    bool isSelect = false,
  }) {
    return ListTile(
      leading: CustomNetworkImage(
        height: 48.r,
          width: 48.r,
          boxShape: BoxShape.circle,
          imageUrl: imageUrl ?? ''),
      title: CustomText(
          textAlign: TextAlign.start,
          text: title ?? '',fontSize: 16.sp),
      subtitle: CustomText(
          textAlign: TextAlign.start,
          text: 'Mother tree : ${description ?? ''}',fontSize: 10.sp),
      trailing: CustomButton(
        width: 69.w,
        height: 38.h,
        backgroundColor: isSelect ? AppColors.primaryColor : Colors.transparent,
        bordersColor:  isSelect ? null : AppColors.primaryColor,
        foregroundColor: isSelect ?  Colors.white : AppColors.primaryColor,
        fontSize: 10.sp,
        label: isSelect ? 'Deselect' : 'Select',onPressed: (){},),
      onTap: () {
        isSelect = !isSelect;
        setState(() {});
      },
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.colorE6E6E6),
        borderRadius: BorderRadius.circular(100.r),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.r,vertical: 0),

    );
  }
}
