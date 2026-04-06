import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_task/core/widgets/widgets.dart';
import 'package:get/get.dart';
import '../widgets/app_logo.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  final String role = Get.arguments['role'];

  final TextEditingController _otpController = TextEditingController();




  @override
  Widget build(BuildContext context) {
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
              key: _globalKey,
              child: CustomPinCodeTextField(
                textEditingController: _otpController,
              ),
            ),

            SizedBox(height: 56.h),

                  CustomButton(
                      label: "Verify",
                      onPressed: _onTapNextScreen,
                    ),
            SizedBox(height: 18.h),
          ],
        ),
      ),
    );
  }

  void _onTapNextScreen() async {
    if (!_globalKey.currentState!.validate()) return;
  }


}
