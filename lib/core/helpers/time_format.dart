import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeFormatHelper {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static DateTime? parseDate(String? formattedDate) {
    if (formattedDate == null || formattedDate.trim().isEmpty) return null;
    try {
      return DateFormat('MMM dd, yyyy').tryParse(formattedDate.trim());
    } catch (e) {
      debugPrint('❌ parseDate error: $e');
      return null;
    }
  }

  static String formatDateTime(String? date) {
    if (date == null || date.trim().isEmpty) return '-';
    try {
      final dt = DateTime.tryParse(date) ??
          DateFormat('dd/MMM/yyyy').tryParse(date.trim()) ??
          DateFormat('MMM dd, yyyy').tryParse(date.trim());
      if (dt == null) return '-';
      return DateFormat('dd-MMM-yyyy').format(dt);
    } catch (e) {
      debugPrint('❌ formatDateTime error for "$date": $e');
      return '-';
    }
  }

  static String? parseToIso(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    try {
      return parseDate(text.trim())?.toUtc().toIso8601String();
    } catch (e) {
      debugPrint('❌ parseToIso error: $e');
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
    return DateFormat('h:mm a').format(time.add(const Duration(hours: 6)));
  }

  static String getDayName(String? dateString) {
    if (dateString == null || dateString.trim().isEmpty) return '-';
    try {
      return DateFormat('EEEE').format(DateTime.parse(dateString).toLocal());
    } catch (e) {
      debugPrint('❌ getDayName error: $e');
      return '-';
    }
  }

  static String getDate(String? dateString) {
    if (dateString == null || dateString.trim().isEmpty) return '-';
    try {
      return DateFormat('dd MMMM').format(DateTime.parse(dateString).toLocal());
    } catch (e) {
      debugPrint('❌ getDate error: $e');
      return '-';
    }
  }

  static String getMonth(String? dateString) {
    if (dateString == null || dateString.trim().isEmpty) return '-';
    try {
      return DateFormat('MMMM').format(DateTime.parse(dateString).toLocal());
    } catch (e) {
      debugPrint('❌ getMonth error: $e');
      return '-';
    }
  }

  static String formatMonthOrDate(String? date) {
    if (date == null || date.trim().isEmpty) return '-';
    try {
      return DateFormat('MMM d').format(DateTime.parse(date).toLocal());
    } catch (e) {
      debugPrint('❌ formatMonthOrDate error: $e');
      return '-';
    }
  }
}