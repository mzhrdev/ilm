
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_fonts.dart';



class CustomElevatedPasswordTextField extends StatefulWidget {
  const CustomElevatedPasswordTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.keyboardType,
    required this.textInputAction,
    required this.validator,
    this.savedValue,
    this.readOnly = false,
    this.isPrefixIconEnabled = false,
    this.preFixIcon = Icons.abc,
    this.contentPadding = const EdgeInsets.fromLTRB(12, 21, 12, 14),
    this.textAlign = TextAlign.start,
    this.fontColor = AppColors.kPrimary,
    this.enabledBorderColor = AppColors.kWhite,
    this.onTap,
    this.isSuffixIconEnabled = true,
    this.suffixIcon = Icons.abc,
    this.labelColor = AppColors.kGrey, //AppColors.kPrimary changed
    this.floatingLabelBehavior = FloatingLabelBehavior.auto,
    this.hintTextColor = AppColors.kGrey, //AppColors.kBlack changed
    this.minLines = 1,
    this.hintFontSize = 14,
    this.inputFormatters,
    this.textStyle,
    this.borderRadius = 15,
    this.fontSize = 14,
    this.prefix,
    this.textFontFamily = AppFonts.kRegular,
    this.hintFontFamily = AppFonts.kRegular,
    this.focusedBorderColor = AppColors.kWhite,
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
  final void Function(String?)? savedValue;
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
  final TextStyle? textStyle;
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
  State<CustomElevatedPasswordTextField> createState() =>
      _CustomElevatedPasswordTextFieldState();
}

class _CustomElevatedPasswordTextFieldState
    extends State<CustomElevatedPasswordTextField> {
  // Initially password is obscure
  bool _obscureText = true;
  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.kGrey.withAlpha(100),
            spreadRadius: 1,
            blurRadius: 7,
            offset: Offset(0, 5), // horizontal, vertical offset
          ),
        ],
      ),
      child: TextFormField(
        cursorColor: widget.cursorColor,
        inputFormatters: widget.inputFormatters,
        textCapitalization: widget.textCapitalization,
        textAlign: widget.textAlign,
        readOnly: widget.readOnly,
        controller: widget.controller,
        style: TextStyle(
          color: widget.fontColor,
          fontSize: widget.fontSize,
          fontFamily: widget.textFontFamily,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: widget.hintTextColor,
            fontSize: widget.hintFontSize,
            fontFamily: widget.hintFontFamily,
          ),
          fillColor: widget.fillColor,
          filled: widget.filled,
          floatingLabelBehavior: widget.floatingLabelBehavior,
          labelText: widget.labelText,
          labelStyle: TextStyle(
            fontSize: widget.labelFontSize,
            color: widget.labelColor,
            fontFamily: widget.labelFontFamily,
          ),
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: widget.enabledBorderColor,
              width: widget.borderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: widget.focusedBorderColor,
              width: widget.borderWidth,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: AppColors.kRed,
              width: widget.borderWidth,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: AppColors.kRed,
              width: widget.borderWidth,
            ),
          ),
          prefixIcon: widget.isPrefixIconEnabled!
              ? Icon(widget.preFixIcon, color: widget.prefixIconColor)
              : null,
          suffixIcon: widget.isSuffixIconEnabled!
              ? IconButton(
                  onPressed: _toggle,
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: widget.suffixIconColor,
                  ),
                )
              : null,
          contentPadding: widget.contentPadding,
        ),
        obscuringCharacter: '\u2022',
        obscureText: _obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        validator: widget.validator,
        onSaved: widget.savedValue,
        onTapOutside: (_) {
          FocusManager.instance.primaryFocus!.unfocus();
        },
      ),
    );
  }
}
