import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
import 'package:flutter_task/core/helpers/toast_message_helper.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/features/auth/domain/services/auth_services.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthService _authService;

  static AuthController get to => Get.find();


  AuthController({required AuthService authService})
    : _authService = authService;

  /// ─── STATE ─────────────────────────────
  LoadingState _loginState = LoadingState.initial;
  LoadingState _registerState = LoadingState.initial;
  LoadingState _otpState = LoadingState.initial;
  LoadingState _forgotState = LoadingState.initial;
  LoadingState _resetState = LoadingState.initial;
  LoadingState _changeState = LoadingState.initial;


  LoadingState get loginState => _loginState;

  LoadingState get registerState => _registerState;

  LoadingState get otpState => _otpState;

  LoadingState get forgotState => _forgotState;

  LoadingState get resetState => _resetState;
  LoadingState get changeState => _changeState;

  bool checked = false;

  void toggleCheckbox(value) {
    checked = value;
    update();
  }

  /// ─── FORM ──────────────────────────────

  final  fastNameController = TextEditingController();
  final  lastNameController = TextEditingController();
  final emailController = TextEditingController(text: kDebugMode ? 'mohammad@gmail.com' : '');
  final currentController = TextEditingController();
  final passwordController = TextEditingController(text: kDebugMode ? '123456' : '');
  final confirmPasswordController = TextEditingController();
  final otpController = TextEditingController();
  final  phoneController = TextEditingController();



  ///



  /// Separate keys for login and register forms
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();
  final otpFormKey = GlobalKey<FormState>();
  final forgotFormKey = GlobalKey<FormState>();
  final resetFormKey = GlobalKey<FormState>();
  final formKey = GlobalKey<FormState>();

  /// ─── LOGIN ─────────────────────────────
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    _loginState = LoadingState.loading;
    update();

    try {
      final userModel = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      _loginState = LoadingState.loaded;
      update();
      if(userModel.isVerified == true){
        // if(userModel.treeJoinStatus == 'unlinked' && userModel.role == 'user'){
        //   Get.offAllNamed(AppRoutes.motherSelectScreen);
        //   return;
        // }
        if(userModel.role == 'superAdmin'){
          Get.offAllNamed(AppRoutes.homeScreen);
        }else{
        Get.offAllNamed(AppRoutes.bottomNavUserBar);}
      }else{
        Get.toNamed(AppRoutes.otpScreen, arguments: 'signup');
      }
      clearControllers();
    } catch (e) {
      _loginState = LoadingState.error;
      update();
      ToastMessageHelper.show(e.errorMessage);
    }
  }

  /// ─── REGISTER ──────────────────────────
  Future<void> register() async {
    if (!registerFormKey.currentState!.validate() || !checked) return;

    _registerState = LoadingState.loading;
    update();
    try {
      await _authService.register(
        name: '${fastNameController.text.trim()} ${lastNameController.text.trim()}',
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        confirmPassword: confirmPasswordController.text,
      );
      _registerState = LoadingState.loaded;
      update();
      Get.toNamed(AppRoutes.otpScreen, arguments: 'signup');
      clearControllers();
    } catch (e) {
      _registerState = LoadingState.error;
      update();
      ToastMessageHelper.show(e.errorMessage);
    }
  }

  /// ─── verify email ──────────────────────────
  Future<bool> otp() async {
    if (!otpFormKey.currentState!.validate()) return false;

    _otpState = LoadingState.loading;
    update();
    try {
      await _authService.otpVerify(
        email: emailController.text.trim(),
        otp: otpController.text.trim(),
      );
      _otpState = LoadingState.loaded;
      update();
      return true;
    } catch (e) {
      _otpState = LoadingState.error;
      update();
      ToastMessageHelper.show(e.errorMessage);
      return false;
    }
  }

  /// ─── forgot email ──────────────────────────
  Future<void> forgot() async {
    if (!forgotFormKey.currentState!.validate()) return;

    _forgotState = LoadingState.loading;
    update();
    try {
      await _authService.forgotPassword(emailController.text.trim());
      _forgotState = LoadingState.loaded;
      update();
      Get.toNamed(AppRoutes.otpScreen, arguments: 'forgot');
      //clearControllers();
    } catch (e) {
      _forgotState = LoadingState.error;
      update();
      ToastMessageHelper.show(e.errorMessage);
    }
  }

  /// ─── verify email ──────────────────────────
  Future<void> resetPassword() async {
    if (!resetFormKey.currentState!.validate()) return;

    _resetState = LoadingState.loading;
    update();
    try {
      await _authService.resetPassword(

        newPassword: confirmPasswordController.text,
      );
      _resetState = LoadingState.loaded;
      update();
      Get.offAllNamed(AppRoutes.bottomNavUserBar);
      clearControllers();
    } catch (e) {
      _resetState = LoadingState.error;
      update();
      ToastMessageHelper.show(e.errorMessage);
    }
  }

  Future<void> changePassword() async {
    if (!formKey.currentState!.validate()) return;
    _changeState = LoadingState.loading;
    update();
    try {
      await _authService.changePassword(
        oldPassword: currentController.text,
        newPassword: confirmPasswordController.text,
      );
      _changeState = LoadingState.loaded;
      update();
      Get.back(canPop: true);
      clearControllers();

    } catch (e) {
      _changeState = LoadingState.error;
      update();
      ToastMessageHelper.show(e.errorMessage);
    }
  }

  /// ─── LOGOUT ────────────────────────────
  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed(AppRoutes.loginScreen);
  }

  /// ─── IS LOGGED IN ──────────────────────
  bool isLoggedIn() => _authService.isLoggedIn();

  bool isAdmin() {
    final user = _authService.getCachedUser();
    if (user != null) {
      return user.role == 'superAdmin';
    }
    return false;
  }





  void clearControllers() {
    confirmPasswordController.clear();
    otpController.clear();
    currentController.clear();
    //emailController.clear();
    passwordController.clear();
    phoneController.clear();
    fastNameController.clear();
    lastNameController.clear();
  }

  /// ─── DISPOSE ───────────────────────────
  @override
  void onClose() {
    confirmPasswordController.dispose();
    otpController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    fastNameController.dispose();
    lastNameController.dispose();
    currentController.dispose();
    super.onClose();
  }
}
