import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:get/get.dart';


class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _numberController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(title: "Contact"),
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

            // ── Fields ─────────────────────────────────────────────────────
            CustomTextField(
              labelText: 'Phone no',
              showShadow: false,
              borderColor: AppColors.colorE6E6E6,
              filColor: AppColors.bgColor,
              controller: _numberController,
              hintText: "Write here...",
            ),
            CustomTextField(
              labelText: 'Email',
              showShadow: false,
              borderColor: AppColors.colorE6E6E6,
              filColor: AppColors.bgColor,
              controller: _emailController,
              hintText: "Write here...",
            ),
            CustomTextField(
              labelText: 'Linkedin link',
              showShadow: false,
              borderColor: AppColors.colorE6E6E6,
              filColor: AppColors.bgColor,
              controller: _linkedinController,
              hintText: "Write here...",
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
