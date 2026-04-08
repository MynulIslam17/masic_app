import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/theme/app_colors.dart';
import 'package:flutter_task/core/utils/assets_path/assets.gen.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:flutter_task/features/translation/presentation/controller/translation_controller.dart';
import 'package:flutter_task/features/translation/presentation/widget/language_picker.dart';
import 'package:get/get.dart';
import '../widgets/app_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();


  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();




  @override
  Widget build(BuildContext context) {
    final controller = TranslationController.to;

    return CustomScaffold(
      paddingSide: 24.w,
      appBar: CustomAppBar(

        actions: [
          Obx(() => GestureDetector(
           onTap: () => LanguagePicker.show(context),
            child: CustomContainer(
              bordersColor: Colors.white,
              horizontalMargin: 16.r,
              color: AppColors.primaryColor,
              paddingHorizontal: 12.r,
              paddingVertical: 4.r,
              radiusAll: 12.r,
              child: CustomText(
                text: '${controller.currentFlag} ${controller.currentCode}',
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          )),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _globalKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(height: 44.h),
              Center(child: AppLogo()),
              SizedBox(height: 20.h),
              CustomTextField(
                prefixIcon: Assets.icons.email.svg(),
                controller: _emailController,
                hintText: "Enter your email",
                keyboardType: TextInputType.emailAddress,
                isEmail: true,
              ),

              SizedBox(height: 10.h),
              CustomTextField(
                prefixIcon: Assets.icons.password.svg(),
                controller: _passwordController,
                hintText: "Password",
                isPassword: true,

              ),
              SizedBox(height: 4.h),
                 GestureDetector(
                   onTap: () => Get.toNamed(AppRoutes.forgotScreen),
                   child: CustomText(
                    fontSize: 12.sp,
                    color: AppColors.primaryColor,

                    text: "Forgot Password?",
                                   ),
                 ),

              SizedBox(height: 44.h),




                    CustomButton(
                    label: "Log in",
                    onPressed: _onSingUp,
                  ),

              SizedBox(height: 18.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: "Don’t have an account? ",
                    fontSize: 14.sp,
                    color: AppColors.colorB0B0B0,
                  ),
                  GestureDetector(
                  //  onTap: () => Get.toNamed(AppRoutes.signUpScreen),
                    child: CustomText(
                      text: "Sign up",
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

  void _onSingUp() {
    if (_globalKey.currentState!.validate()) return;
    Get.offAllNamed(AppRoutes.bottomNavUserBar);
  }
}
