import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Closes the dialog that triggered an action once the action finishes.
///
/// The app opens dialogs with Flutter's `showDialog`, which GetX does not
/// track — `Get.isDialogOpen` is only true for `Get.dialog`. Checking it meant
/// "Give/Decline admin" and "Delete user" ran but left the dialog on screen.
/// This looks at the actual top route and pops it only if it is a popup
/// (dialog / bottom sheet), so it can never pop the page underneath.
class DialogCloseHelper {
  DialogCloseHelper._();

  static bool isPopupOnTop([NavigatorState? navigator]) {
    final nav = navigator ?? Get.key.currentState;
    if (nav == null) return false;
    var top = false;
    nav.popUntil((route) {
      top = route is PopupRoute;
      return true; // inspect only, never pop
    });
    return top;
  }

  /// Pops the top route if it is a dialog/popup. Returns whether it closed.
  static bool closeIfOpen([NavigatorState? navigator]) {
    final nav = navigator ?? Get.key.currentState;
    if (nav == null || !isPopupOnTop(nav)) return false;
    nav.pop();
    return true;
  }
}
