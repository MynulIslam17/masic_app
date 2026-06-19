import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/auth/presentation/widgets/app_logo.dart';
import 'package:masic_generation/features/translation/presentation/controller/translation_controller.dart';
import 'package:masic_generation/features/translation/presentation/widget/language_picker.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  @override
  Widget build(BuildContext context) {
    final  translationController = TranslationController.to;
    final AuthController to = AuthController.to;

    return CustomScaffold(
      paddingSide: 24.w,
      appBar: CustomAppBar(
        actions: [
          Obx(() => GestureDetector(
           behavior: HitTestBehavior.opaque,
           onTap: () => LanguagePicker.show(context),
            child: CustomContainer(
              bordersColor: Colors.white,
              horizontalMargin: 16.r,
              color: AppColors.primaryColor,
              paddingHorizontal: 12.r,
              paddingVertical: 4.r,
              radiusAll: 12.r,
              child: CustomText(
                text: '${translationController.currentFlag} ${translationController.currentCode}',
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
          key: to.loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(height: 44.h),
              Center(child: AppLogo()),
              SizedBox(height: 20.h),
              CustomTextField(
                prefixIcon: Assets.icons.email.svg(),
                controller: to.emailController,
                hintText: "Enter your email",
                keyboardType: TextInputType.emailAddress,
                isEmail: true,
              ),

              SizedBox(height: 10.h),
              CustomTextField(
                prefixIcon: Assets.icons.password.svg(),
                controller: to.passwordController,
                hintText: "Password",
                isPassword: true,

              ),
              SizedBox(height: 4.h),
                 GestureDetector(
                   behavior: HitTestBehavior.opaque,
                   onTap: () => Get.toNamed(AppRoutes.forgotScreen),
                   child: CustomText(
                    fontSize: 12.sp,
                    color: AppColors.primaryColor,

                    text: "Forgot Password?",
                                   ),
                 ),

              SizedBox(height: 44.h),




                    GetBuilder<AuthController>(
                      builder: (controller) {
                        return CustomButton(
                        label: "Log in",
                        isLoading: controller.loginState.isLoading,
                        onPressed: controller.login,
                                          );
                      }
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
                   behavior: HitTestBehavior.opaque,
                   onTap: () => Get.toNamed(AppRoutes.signUpScreen),
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

}
