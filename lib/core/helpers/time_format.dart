import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeFormatHelper {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date); //western date format
  }

  static DateTime parseDate(String formattedDate) {
    return DateFormat('MMM dd, yyyy').parse(formattedDate);
  }

  static String formatDateTime(String date) {
    DateTime dt;
    try {
      dt = DateTime.parse(date);
    } catch (_) {
      dt = DateFormat('dd/MMM/yyyy').parse(date);
    }
    return DateFormat('dd/MMM/yyyy').format(dt);
  }

  static String? parseToIso(String text) {
    if (text.trim().isEmpty) return null;
    try {
      return TimeFormatHelper.parseDate(text.trim()).toUtc().toIso8601String();
    } catch (e) {
      debugPrint('❌ Date parse error: $e');
      return null;
    }
  }

  static String formatDateWithHifen(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String dateMountFormat(DateTime date) {
    return DateFormat('dd\n MMM ').format(date);
  }

  static String dateWeek(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  static String timeFormat(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String timeWithAMPM(DateTime time) {
    // DateTime parsedTime = DateFormat('HH:mm:ss').parse(time);

    String formattedTime = DateFormat(
      'h:mm a',
    ).format(time.add(const Duration(hours: 6)));
    return formattedTime;
  }

  static String getDayName(String dateString) {
    DateTime dateTime = DateTime.parse(dateString).toLocal(); // Local timezone
    return DateFormat('EEEE').format(dateTime); // Full day name
  }

  static String getDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString).toLocal(); // Local timezone
    return DateFormat('dd MMMM').format(dateTime); // Only day (date)
  }

  static String getMonth(String dateString) {
    DateTime dateTime = DateTime.parse(dateString).toLocal(); // Local timezone
    return DateFormat('MMMM').format(dateTime); // Only day (date)
  }

  static String formatMonthOrDate(String date) {
    DateTime dateTime = DateTime.parse(date).toLocal(); // Local timezone

    return DateFormat('MMM d').format(dateTime);
  }

  // static String getTimeAgo(DateTime postTime) {
  //   String time = timeago.format(postTime);
  //   return time
  //       .replaceAll('seconds', 'sec')
  //       .replaceAll('second', 'sec')
  //       .replaceAll('minutes', 'min')
  //       .replaceAll('minute', 'min')
  //       .replaceAll('hours', 'hr')
  //       .replaceAll('hour', 'hr');
  // }

  // static Future<void> isFutureDate(String input) async {
  //   try {
  //     DateTime date = DateTime.parse(input);
  //     DateTime now = DateTime.now();
  //     await PrefsHelper.setBool(AppConstants.isFutureDate, date.isAfter(now));
  //   } catch (e) {
  //     PrefsHelper.setBool(AppConstants.isFutureDate, false);
  //   }
  // }
  //
}
