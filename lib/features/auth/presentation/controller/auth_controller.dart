import 'package:masic_generation/core/helpers/app_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/helpers/toast_message_helper.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/features/auth/data/models/user_response_model.dart';
import 'package:masic_generation/core/services/push_notification_service.dart';
import 'package:masic_generation/features/auth/domain/services/auth_services.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';
import 'package:masic_generation/core/helpers/dialog_close_helper.dart';
import 'package:masic_generation/core/widgets/native_loading_dialog.dart';

class AuthController extends GetxController {
  final AuthService _authService;
  final PushNotificationService _pushNotificationService;

  static AuthController get to => Get.find();

  AuthController({
    required AuthService authService,
    required PushNotificationService pushNotificationService,
  })  : _authService = authService,
        _pushNotificationService = pushNotificationService;

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
  final  arabicNameController = TextEditingController();
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
      final fcmToken = await _pushNotificationService.getToken();
      final userModel = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
        fcmToken: fcmToken,
      );
      _loginState = LoadingState.loaded;
      update();
      if (userModel.isVerified == true) {
        await syncPushTokenWithServer();
        await navigateAuthenticatedUser(user: userModel);
      } else {
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
  /// Flow: sign-up -> OTP -> setup profile -> Select Mother Tree. The mother
  /// tree is chosen after the account exists (`POST /member/choose-mother`).
  Future<void> register() async {
    if (_registerState == LoadingState.loading) return;
    if (!registerFormKey.currentState!.validate()) return;
    if (!checked) {
      ToastMessageHelper.show(
        'Please accept the Terms & Conditions & Privacy Policy',
      );
      return;
    }

    _registerState = LoadingState.loading;
    update();
    try {
      final fcmToken = await _pushNotificationService.getToken();
      await _authService.register(
        name: '${fastNameController.text.trim()} ${lastNameController.text.trim()}',
        arabicName: arabicNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        confirmPassword: confirmPasswordController.text,
        fcmToken: fcmToken,
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
      final fcmToken = await _pushNotificationService.getToken();
      await _authService.otpVerify(
        email: emailController.text.trim(),
        otp: otpController.text.trim(),
        fcmToken: fcmToken,
      );
      await syncPushTokenWithServer();
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
      clearControllers();
      await _authService.logout();
      Get.offAllNamed(AppRoutes.loginScreen);
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

  /// Registers this device's FCM token with the backend when a session exists.
  Future<void> syncPushTokenWithServer() async {
    if (!isLoggedIn()) return;
    final token = await _pushNotificationService.getToken();
    if (token == null || token.isEmpty) return;
    await _authService.syncFcmToken(token);
  }

  /// ─── LOGOUT ────────────────────────────
  ///
  /// Re-entrant safe: a 401 from a request that was still in flight can call
  /// this again, and a second [Get.offAllNamed] would leave two login screens
  /// in the tree fighting over the same form [GlobalKey].
  bool _loggingOut = false;

  Future<void> logout({bool showProgress = true}) async {
    if (_loggingOut) return;
    _loggingOut = true;
    try {
      // Swap the "Are you sure?" dialog for a blocking native spinner so the
      // user can't tap twice or navigate while the session is torn down.
      DialogCloseHelper.closeIfOpen();
      if (showProgress) {
        await NativeLoadingDialog.show(message: 'Logging out...');
      }
      try {
        // Firebase can stall without network; never block logout on it.
        await _pushNotificationService.deleteToken().timeout(
          const Duration(seconds: 5),
        );
      } catch (e) {
        AppLog.warn('Auth', 'Logout: push token cleanup skipped: $e');
      }
      await _authService.logout();
      clearControllers();
      // Replaces every route, the progress dialog included.
      Get.offAllNamed(AppRoutes.loginScreen);
    } finally {
      NativeLoadingDialog.hide();
      _loggingOut = false;
    }
  }

  /// ─── IS LOGGED IN ──────────────────────
  bool isLoggedIn() => _authService.isLoggedIn();

  UserResponseModel? get cachedUser => _authService.getCachedUser();

  static bool isAdminRole(String? role) {
    final key = (role ?? '').trim().toLowerCase();
    return key == 'admin' || key == 'superadmin' || key == 'super_admin';
  }

  static bool isSuperAdminRole(String? role) {
    final key = (role ?? '').trim().toLowerCase();
    return key == 'superadmin' || key == 'super_admin';
  }

  bool isAdmin() => isAdminRole(cachedUser?.role);

  bool isSuperAdmin() => isSuperAdminRole(cachedUser?.role);

  /// Admins, and users already placed in the family tree, may use the app.
  /// Everyone else must finish the Select Mother Tree page first.
  bool get hasAppAccess =>
      isAdmin() || cachedUser?.treeJoinStatus == 'placed';

  Future<void> navigateAuthenticatedUser({UserResponseModel? user}) async {
    final currentUser = user ?? _authService.getCachedUser();
    if (currentUser == null) {
      Get.offAllNamed(AppRoutes.loginScreen);
      return;
    }

    if (isAdminRole(currentUser.role)) {
      Get.offAllNamed(AppRoutes.adminBottomNavBar);
      ProfileController.to.loadDataIfNeeded();
      return;
    }

    // The app was closed between OTP and Setup Profile: resume there.
    if (_authService.isProfileSetupPending) {
      ProfileController.to.beginOnboarding();
      Get.offAllNamed(AppRoutes.editProfileScreen, arguments: 'onboarding');
      return;
    }

    final treeStatus = await ProfileController.to.resolveTreeJoinStatus(
      cachedStatus: currentUser.treeJoinStatus,
      // A status straight from the login response needs no second request.
      isFresh: user != null,
    );

    // The status check can end the session (expired token, deleted
    // account); the user is already on the login screen in that case.
    if (!isLoggedIn()) return;

    if (treeStatus == 'placed') {
      await _authService.syncTreeJoinStatus('placed');
      Get.offAllNamed(AppRoutes.bottomNavUserBar);
      ProfileController.to.loadDataIfNeeded();
      return;
    }

    // The Select Mother Tree page loads its own list; the profile and member
    // directory are loaded once the user is placed.
    Get.offAllNamed(AppRoutes.motherSelectScreen);
  }





  void clearControllers() {
    confirmPasswordController.clear();
    otpController.clear();
    currentController.clear();
    passwordController.clear();
    phoneController.clear();
    fastNameController.clear();
    lastNameController.clear();
    arabicNameController.clear();
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
    arabicNameController.dispose();
    currentController.dispose();
    super.onClose();
  }
}
