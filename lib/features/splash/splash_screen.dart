import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/theme/app_colors.dart';
import 'package:masic_generation/core/utils/assets_path/assets.gen.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {



  void _goNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    if (AuthController.to.isLoggedIn()) {
      await AuthController.to.syncPushTokenWithServer();
      await AuthController.to.navigateAuthenticatedUser();
    } else {
      Get.offAllNamed(AppRoutes.loginScreen);
    }
  }

  @override
  void initState() {
   _goNextScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Center(
        child: Assets.icons.logo.svg(height: 170.h,width: 183.w),
      ),
    );
  }
}
