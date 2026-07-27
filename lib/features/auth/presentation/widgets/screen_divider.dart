import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';

class ScreenDivider extends StatelessWidget {
  final String text;
  final double thickness;
  final double indent;
  final TextStyle? textStyle;
  final Color? color;

  const ScreenDivider({
    super.key,
    required this.text,
    this.thickness = 1.0,
    this.indent = 16.0,
    this.textStyle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Fallback to theme colors if no explicit color is provided
    final dividerColor = color ?? Theme.of(context).dividerColor;

    return Row(
      children: [
        // Left Line
        Expanded(
          child: Divider(thickness: thickness, color: dividerColor),
        ),

        // Middle Text with explicit horizontal padding
        Text(
          text,
          style:
              textStyle ??
              Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: dividerColor, fontWeight: FontWeight.w500),
        ).padHrz(indent),

        // Right Line
        Expanded(
          child: Divider(thickness: thickness, color: dividerColor),
        ),
      ],
    );
  }
}
