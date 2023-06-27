import 'package:flutter/material.dart';

const brandGoldColor = Color(0xFFE5AC00);
const brandDarkBlueColor = Color(0xFF06263E);

// const primarySwatch = MaterialColor(0xff182b1d, {
//   50: Color(0xff808a83),
//   100: Color(0xff748077),
//   200: Color(0xff5d6b61),
//   300: Color(0xff46554a),
//   400: Color(0xff2f4034),
//   500: Color(0xff182b1d),
//   600: Color(0xff16271a),
//   700: Color(0xff132217),
//   800: Color(0xff111e14),
//   900: Color(0xff0e1a11),
// });

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}
