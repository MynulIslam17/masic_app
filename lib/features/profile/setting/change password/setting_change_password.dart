import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/auth/presentation/controller/auth_controller.dart';
import 'package:get/get.dart';


class SettingChangePassword extends StatefulWidget {
  const SettingChangePassword({super.key});

  @override
  State<SettingChangePassword> createState() => _SettingChangePasswordState();
}

class _SettingChangePasswordState extends State<SettingChangePassword> {

  @override
  Widget build(BuildContext context) {
    final controller = AuthController.to;
    return CustomScaffold(
      paddingSide: 24.w,
      appBar: CustomAppBar(
        title: 'Change Password',
      ),
      body: SingleChildScrollView(
        child: Form(
          key: controller.formKey,
          child: Column(
            //spacing: 10.h,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 24.h,
              ),
              CustomTextField(
                showShadow: false,
                labelText: 'Old Password',
                controller: controller.currentController,
                hintText: "Old Password",
                isPassword: true,
              ),
              CustomTextField(
                showShadow: false,
                labelText: 'New Password',
                controller: controller.passwordController,
                hintText: "New Password",
                isPassword: true,
              ),
              CustomTextField(
                showShadow: false,
                labelText: 'Confirm Password',
                controller: controller.confirmPasswordController,
                hintText: "Confirm Password",
                isPassword: true,
                validator: (value) {
                  if (value != controller.passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                }
              ),

        SizedBox(height: 60.h,),
              GetBuilder<AuthController>(
                builder: (controller) {
                  return CustomButton(
                      label: "Update",
                      isLoading: controller.changeState.isLoading,
                      onPressed: controller.changePassword,
                      );
                }
              ),
              SizedBox(
                height:32.h,
              ),
            ],
          ),
        ),
      ),
    );
  }


}
