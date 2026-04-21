import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/auth/widgets/app_logo.dart';
import 'package:get/get.dart';





class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  final TextEditingController _fastNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();




  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      paddingSide: 24.w,
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Form(
          key: _globalKey,
          child: Column(
            spacing: 4.h,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SizedBox(height: 24.h),
              AppLogo(
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                prefixIcon: Assets.icons.person.svg(),
                labelText: 'First Name',
                controller: _fastNameController,
                hintText: "Enter your first name",
              ), CustomTextField(
                prefixIcon: Assets.icons.person.svg(),
                labelText: 'Last Name',
                controller: _lastNameController,
                hintText: "Enter your last name",
              ),

              CustomTextField(
                prefixIcon: Assets.icons.email.svg(),
                labelText: 'Email',
                controller: _emailController,
                hintText: "Enter your email",
                keyboardType: TextInputType.emailAddress,
                isEmail: true,
              ),

              CustomTextField(
                prefixIcon: Assets.icons.number.svg(),
                labelText: 'Phone Number',
                controller: _phoneController,
                hintText: "Enter your number",
                keyboardType: TextInputType.number,
              ),
              CustomTextField(
                prefixIcon: Assets.icons.password.svg(),
                labelText: 'Password',
                controller: _passwordController,
                hintText: "Enter your password",
                isPassword: true,
              ),
              CustomTextField(
                prefixIcon: Assets.icons.password.svg(),
                labelText: 'Confirm Password',
                controller: _confirmPassController,
                hintText: "Confirm Password",
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirm password is required';
                  } else if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                         Checkbox(
                          value: true,
                          onChanged: (value) {},
                          activeColor: AppColors.primaryColor,
                        ),

                  CustomText(
                    text: "I accept the Terms & Conditions & Privacy Policy",
                    fontSize: 11.sp,
                    // color: AppColors.textColor4D4D4D,
                  ),
                ],
              ),

              SizedBox(height: 44.h),

               CustomButton(label: "Sign Up", onPressed: _onSignUp),

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

  void _onSignUp() {
    if (!_globalKey.currentState!.validate()) return;
  }

}

