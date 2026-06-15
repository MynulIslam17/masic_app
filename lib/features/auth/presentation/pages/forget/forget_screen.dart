import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/auth/presentation/widgets/app_logo.dart';
import 'package:get/get.dart';

class ForgetScreen extends StatelessWidget {
  const ForgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController to = AuthController.to;
    return CustomScaffold(
      paddingSide: 24.w,
      appBar:  CustomAppBar(title: 'E-mail Verification'),
      body: SingleChildScrollView(
        child: Form(
          key: to.forgotFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 44.h),
              AppLogo(
              ),
              SizedBox(height: 40.h),
              CustomTextField(
                prefixIcon: Assets.icons.email.svg(),
                controller: to.emailController,
                hintText: "Enter your email",
                keyboardType: TextInputType.emailAddress,
                isEmail: true,
              ),
              SizedBox(height: 54.h),

                    GetBuilder<AuthController>(
                      builder: (to) {
                        return CustomButton(
                        label: "Send OTP",
                        isLoading: to.forgotState.isLoading,
                        onPressed: to.forgot,
                                          );
                      }
                    ),


              SizedBox(height: 18.h),
            ],
          ),
        ),
      ),
    );
  }

}
