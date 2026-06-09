import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get h1 => GoogleFonts.lato(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.sageDark,
        letterSpacing: -0.5,
      );

  static TextStyle get h2 => GoogleFonts.lato(
        fontSize: 24,
        fontWeight: FontWeight.w600, // SemiBold
        color: AppColors.sageDark,
      );

  static TextStyle get bodyMax => GoogleFonts.lato(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textDark,
      );

  static TextStyle get bodyMedium => GoogleFonts.lato(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textDark,
      );

  static TextStyle get caption => GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.w300, // Light
        color: AppColors.textLight,
      );

  static TextStyle get buttonLabel => GoogleFonts.lato(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );
}
