import 'package:flutter/material.dart';
import 'package:Edvance/core/constants/app_fonts.dart';

class AppTextStyle {
  // Headings & Prominent Titles
  static const TextStyle kHeading = TextStyle(fontSize: 22, fontFamily: AppFonts.kBold);
  static const TextStyle kDisplayTitle = TextStyle(fontSize: 20, fontFamily: AppFonts.kRegular);
  static const TextStyle kSectionTitle = TextStyle(fontSize: 18, fontFamily: AppFonts.kLight);

  // Body Texts (Primary Content)
  static const TextStyle kBodyLarge = TextStyle(fontSize: 16, fontFamily: AppFonts.kLight);
  static const TextStyle kBodyMedium = TextStyle(fontSize: 14, fontFamily: AppFonts.kLight);

  // Secondary Metadata & Supporting Texts
  static const TextStyle kBodySmall = TextStyle(fontSize: 12, fontFamily: AppFonts.kLight);
  static const TextStyle kCaption = TextStyle(fontSize: 10, fontFamily: AppFonts.kLight);
}
