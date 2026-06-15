import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/auth/presentation/widgets/app_logo.dart';
import 'package:get/get.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});


  @override
  Widget build(BuildContext context) {

    final AuthController to = AuthController.to;
    return CustomScaffold(
      appBar:  CustomAppBar(title: 'Reset Password',),
      body: SingleChildScrollView(
        child: Form(
          key: to.resetFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 24.h),
              AppLogo(

              ),


              SizedBox(height: 40.h),
              CustomTextField(
                controller: to.passwordController,
                hintText: "New Password",
                isPassword: true,

              ),



              SizedBox(height: 16.h),

              CustomTextField(
                controller: to.confirmPasswordController,
                hintText: "Confirm Password",
                isPassword: true,

              ),


              SizedBox(height: 36.h),

              GetBuilder<AuthController>(
                builder: (to) {
                  return CustomButton(
                    label: "Reset",
                    isLoading: to.resetState.isLoading,
                    onPressed: to.resetPassword,
                  );
                }
              ),
              SizedBox(height: 44.h),

            ],
          ),
        ),
      ),
    );
  }
}
