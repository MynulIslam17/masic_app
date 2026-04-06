import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTheme {
  AppTheme._();

  // ─── Light Theme ──────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: GoogleFonts.poppinsTextTheme(),

    // AppBar
    appBarTheme: AppBarTheme(
    ),



  );

  // ─── Dark Theme ───────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    //scaffoldBackgroundColor: AppColors.backgroundDark,

    appBarTheme: AppBarTheme(
      iconTheme: const IconThemeData(color: AppColors.textDark),

    ),
  );
}