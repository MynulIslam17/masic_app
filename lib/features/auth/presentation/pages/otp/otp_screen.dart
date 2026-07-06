import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/widgets/widgets.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';
import 'package:masic_generation/features/auth/presentation/widgets/app_logo.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController to = AuthController.to;
    return CustomScaffold(
      appBar: CustomAppBar(title: 'Verification'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 44.h),
            AppLogo(

            ),
            SizedBox(height: 40.h),

            ///==============Pin code Field============<>>>>
            Form(
              key: to.otpFormKey,
              child: CustomPinCodeTextField(
                textEditingController: to.otpController,
              ),
            ),

            SizedBox(height: 56.h),

            GetBuilder<AuthController>(
                builder: (controller) {
                  return CustomButton(
                    isLoading: controller.otpState.isLoading,
                    label: "Verify",
                    onPressed: () async => _onTapNextScreen(controller),
                  );
                }
            ),
            SizedBox(height: 18.h),
          ],
        ),
      ),
    );
  }

  void _onTapNextScreen(AuthController controller) async {
    final String role = Get.arguments as String;

    if (!await controller.otp()) return;
    if (role == 'forgot') {
      Get.toNamed(AppRoutes.resetPasswordScreen);
    } else {
      ProfileController.to.beginOnboarding();
      Get.offAllNamed(AppRoutes.editProfileScreen, arguments: 'onboarding');
    }
  }
}
