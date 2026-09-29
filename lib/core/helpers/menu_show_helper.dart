import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MenuShowHelper {
  static final List<String> heightOptions = List.generate(100, (index) {
    return "${(index ~/ 12) + 4}'${(index % 12)}\" cm";
  });

  static final List<String> weightOptions = List.generate(66, (index) {
    return "${35 + index} kg";
  });

  static final List<String> discounts = List.generate(18, (index) {
    return '${(index + 1) * 5} %';
  });

  static final List<String> discountTime = List.generate(30, (index) {
    return '${index + 1} ${index + 1 == 1 ? 'day' : 'days'}';
  });

  static final List<String> genderOptions = ["Male", "Female"];
  static final List<String> categoryList = [
    'Shirt',
    'Pant',
    'Dress',
    'Shoes',
    'Accessories',
    'Others',
  ];

  static final List<String> sizes = [
    'XS',
    'S',
    'M',
    'L',
    'XL',
    'XXL',
  ];

  /// Shows a popup menu at the tap position from TapDownDetails.
  /// Returns the selected value or null if none selected.
  static Future<String?> showCustomMenu({
    required BuildContext context,
    required TapDownDetails details,
    required List<String> options,
  }) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final Offset tapPosition = details.globalPosition;

    return _show(
      context: context,
      overlay: overlay,
      position: RelativeRect.fromRect(
        Rect.fromPoints(tapPosition, tapPosition),
        Offset.zero & overlay.size,
      ),
      options: options,
    );
  }

  /// Opens the menu under [context]'s widget (the whole dropdown field).
  static Future<String?> showBelow({
    required BuildContext context,
    required List<String> options,
  }) {
    final box = context.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (box == null || overlay == null || !box.hasSize) {
      return Future.value(null);
    }

    final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
    final size = box.size;

    return _show(
      context: context,
      overlay: overlay,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(topLeft.dx, topLeft.dy, size.width, size.height),
        Offset.zero & overlay.size,
      ),
      options: options,
    );
  }

  static Future<String?> _show({
    required BuildContext context,
    required RenderBox overlay,
    required RelativeRect position,
    required List<String> options,
  }) {
    return showMenu<String>(
      context: context,
      color: Colors.white,
      constraints: BoxConstraints(
        maxHeight: 320.h,
        minWidth: 180.w,
        maxWidth: overlay.size.width,
      ),
      position: position,
      items: options.map((String option) {
        return PopupMenuItem<String>(
          value: option,
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              option,
              style: TextStyle(fontSize: 14.sp, color: Colors.black),
            ),
          ),
        );
      }).toList(),
    );
  }
}
