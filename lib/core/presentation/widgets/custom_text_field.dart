import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_fonts.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.keyboardType,
    required this.textInputAction,
    required this.validator,
    this.onSubmitted,
    this.onChanged,
    this.readOnly = false,
    this.isPrefixIconEnabled = false,
    this.preFixIcon = Icons.abc,
    this.contentPadding = const EdgeInsets.fromLTRB(12, 24, 12, 16),
    this.textAlign = TextAlign.start,
    this.fontColor = AppColors.kPrimary,
    this.enabledBorderColor = AppColors.kBlack,
    this.onTap,
    this.isSuffixIconEnabled = false,
    this.suffixIcon = Icons.abc,
    this.labelColor = AppColors.kGrey, //AppColors.kPrimary changed
    this.floatingLabelBehavior = FloatingLabelBehavior.auto,
    this.hintTextColor = AppColors.kGrey, //AppColors.kBlack changed
    this.minLines = 1,
    this.hintFontSize = 14,
    this.inputFormatters,
    this.borderRadius = 15,
    this.fontSize = 14,
    this.prefix,
    this.textFontFamily = AppFonts.kRegular,
    this.hintFontFamily = AppFonts.kRegular,
    this.focusedBorderColor = AppColors.kPrimary,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
    this.cursorColor = AppColors.kPrimary,
    this.labelFontSize = 14,
    this.labelFontFamily = AppFonts.kRegular,
    this.filled = false,
    this.fillColor = AppColors.kPrimary,
    //Only For This App
    this.borderWidth = 1,
    //this.borderWidth = 1.5,
    this.prefixIconColor = AppColors.kBlack,
    this.suffixIconColor = AppColors.kBlack,
  });
  final TextEditingController? controller;
  final bool readOnly;
  final String? hintText;
  final String? labelText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String?)? onSubmitted;
  final void Function(String)? onChanged;
  final bool? isPrefixIconEnabled;
  final IconData? preFixIcon;
  final bool? isSuffixIconEnabled;
  final IconData? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final TextAlign textAlign;
  final Color? fontColor;
  final Color enabledBorderColor;
  final void Function()? onTap;
  final Color? labelColor;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final Color? hintTextColor;
  final int? minLines;
  final double? hintFontSize;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  final double? fontSize;
  final Widget? prefix;
  final String? textFontFamily;
  final String? hintFontFamily;
  final Color focusedBorderColor;
  final int? maxLength;
  final double borderRadius;
  final Color? cursorColor;
  final double? labelFontSize;
  final String? labelFontFamily;
  final bool filled;
  final Color? fillColor;
  final double borderWidth;
  final Color? prefixIconColor;
  final Color? suffixIconColor;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: cursorColor,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      textAlign: textAlign,
      maxLines: null,
      minLines: minLines,
      readOnly: readOnly,
      controller: controller,
      style: TextStyle(color: fontColor, fontSize: fontSize, fontFamily: textFontFamily),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: hintTextColor, fontSize: hintFontSize, fontFamily: hintFontFamily),
        fillColor: fillColor,
        filled: filled,
        floatingLabelBehavior: floatingLabelBehavior,
        labelText: labelText,
        labelStyle: TextStyle(fontSize: labelFontSize, color: labelColor, fontFamily: labelFontFamily),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: enabledBorderColor, width: borderWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: enabledBorderColor, width: borderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: focusedBorderColor, width: borderWidth),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: AppColors.kRed, width: borderWidth),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: AppColors.kRed, width: borderWidth),
        ),
        prefixIcon: isPrefixIconEnabled! ? Icon(preFixIcon, color: prefixIconColor) : null,
        suffixIcon: isSuffixIconEnabled! ? Icon(suffixIcon, color: suffixIconColor) : null,
        contentPadding: contentPadding,
      ),
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      onChanged: onChanged,
      onTap: onTap,
      onTapOutside: (_) {
        //FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );
  }
}
