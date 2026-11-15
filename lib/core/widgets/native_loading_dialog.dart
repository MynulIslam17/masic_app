import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Blocking, platform-native progress dialog ("Logging out…").
///
/// iOS gets the system-style frosted HUD with a [CupertinoActivityIndicator];
/// Android gets a Material dialog with a [CircularProgressIndicator]. It cannot
/// be dismissed by tapping outside or the back gesture — the caller closes it
/// with [hide], or by navigating away (e.g. `Get.offAllNamed`).
class NativeLoadingDialog extends StatelessWidget {
  const NativeLoadingDialog({super.key, required this.message});

  final String message;

  static bool _visible = false;
  static bool get isVisible => _visible;

  static Future<void> show({String message = 'Please wait...'}) async {
    if (_visible) return;
    _visible = true;
    // Not awaited: the dialog stays up while the caller does its work.
    Get.dialog<void>(
      NativeLoadingDialog(message: message),
      barrierDismissible: false,
      barrierColor: Colors.black38,
      useSafeArea: true,
    ).whenComplete(() => _visible = false);
    // Let the route build before the caller starts blocking work.
    await Future<void>.delayed(Duration.zero);
  }

  static void hide() {
    if (!_visible) return;
    if (Get.isDialogOpen == true) Get.back<void>();
    _visible = false;
  }

  @override
  Widget build(BuildContext context) {
    final isCupertino = switch (Theme.of(context).platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => true,
      _ => false,
    };
    return PopScope(
      canPop: false,
      child: Center(
        child: isCupertino ? _cupertino(context) : _material(context),
      ),
    );
  }

  Widget _cupertino(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 150,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          color: CupertinoColors.systemBackground
              .resolveFrom(context)
              .withValues(alpha: 0.85),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CupertinoActivityIndicator(radius: 14),
              const SizedBox(height: 14),
              DefaultTextStyle(
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                textAlign: TextAlign.center,
                child: Text(message),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _material(BuildContext context) {
    return AlertDialog(
      content: Row(
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(width: 20),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
