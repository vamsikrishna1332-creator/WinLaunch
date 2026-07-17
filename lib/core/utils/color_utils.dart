import 'package:flutter/material.dart';

class ColorUtils {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static String toHex(Color color, {bool includeHash = true}) {
    final hex = color.value.toRadixString(16).padLeft(8, '0');
    return includeHash ? '#$hex' : hex;
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  static Color darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  static Color withOpacity(Color color, double opacity) =>
      color.withOpacity(opacity);

  static bool isDark(Color color) => color.computeLuminance() < 0.5;

  static Color contrastingText(Color background) =>
      isDark(background) ? Colors.white : Colors.black;
}
