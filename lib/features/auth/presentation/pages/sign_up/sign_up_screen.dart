import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/auth/presentation/widgets/app_logo.dart';
import 'package:get/get.dart';





class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController to = AuthController.to;
    return CustomScaffold(
      paddingSide: 24.w,
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Form(
          key: to.registerFormKey,
          child: Column(
            spacing: 4.h,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SizedBox(height: 24.h),
              AppLogo(
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                showShadow: false,
                prefixIcon: Assets.icons.person.svg(),
                labelText: 'First Name',
                controller: to.fastNameController,
                hintText: "Enter your first name",
              ), CustomTextField(
                showShadow: false,
                prefixIcon: Assets.icons.person.svg(),
                labelText: 'Last Name',
                controller: to.lastNameController,
                hintText: "Enter your last name",
              ),

              CustomTextField(
                showShadow: false,
                prefixIcon: Assets.icons.email.svg(),
                labelText: 'Email',
                controller: to.emailController,
                hintText: "Enter your email",
                keyboardType: TextInputType.emailAddress,
                isEmail: true,
              ),

              CustomTextField(
                showShadow: false,
                prefixIcon: Assets.icons.number.svg(),
                labelText: 'Phone Number',
                controller: to.phoneController,
                hintText: "Enter your number",
                keyboardType: TextInputType.number,
              ),
              CustomTextField(
                showShadow: false,
                prefixIcon: Assets.icons.password.svg(),
                labelText: 'Password',
                controller: to.passwordController,
                hintText: "Enter your password",
                isPassword: true,
              ),
              CustomTextField(
                showShadow: false,
                prefixIcon: Assets.icons.password.svg(),
                labelText: 'Confirm Password',
                controller: to.confirmPasswordController,
                hintText: "Confirm Password",
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirm password is required';
                  } else if (value != to.passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                         GetBuilder<AuthController>(
                           builder: (to) {
                             return Checkbox(
                              value: to.checked,
                              onChanged: (value) => to.toggleCheckbox(value),
                              activeColor: AppColors.primaryColor,
                                                     );
                           }
                         ),

                  CustomText(
                    text: "I accept the Terms & Conditions & Privacy Policy",
                    fontSize: 11.sp,
                    // color: AppColors.textColor4D4D4D,
                  ),
                ],
              ),

              SizedBox(height: 44.h),

               GetBuilder<AuthController>(
                 builder: (controller) {
                   return CustomButton(
                     isLoading: controller.registerState.isLoading,
                       label: "Sign Up", onPressed: controller.register);
                 }
               ),

              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: 'Already have an account? ',
                    fontSize: 14.sp,
                    color: AppColors.colorB0B0B0,
                  ),
                  GestureDetector(
                    onTap: (){
                      Get.back();
                    },
                    child: CustomText(
                      text: "Sign In",
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}

