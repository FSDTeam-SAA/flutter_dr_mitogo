import 'package:casarancha/app/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.black,
  splashColor: Colors.transparent,
  splashFactory: NoSplash.splashFactory,
  scaffoldBackgroundColor: Colors.white,
  textTheme: GoogleFonts.montserratTextTheme().copyWith(
    bodyLarge: GoogleFonts.montserrat(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: Colors.black87,
    ),
    bodyMedium: GoogleFonts.montserrat(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    ),
    bodySmall: GoogleFonts.montserrat(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Colors.black45,
    ),
    labelMedium: GoogleFonts.montserrat(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.lightGrey,
    ),
    labelLarge: GoogleFonts.montserrat(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
    labelSmall: GoogleFonts.montserrat(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryColor,
    ),
  ),
);
