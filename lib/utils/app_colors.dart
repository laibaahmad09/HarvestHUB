import 'package:flutter/material.dart';

class AppColors {
  static const List<Color> backgroundGradient = [
    Color.fromARGB(255, 228, 237, 216),
    Color.fromARGB(255, 216, 232, 216),
    Color.fromARGB(255, 237, 241, 239),
  ];

  static const List<double> gradientStops = [0.0, 0.5, 1.0];

  static BoxDecoration get backgroundDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: backgroundGradient,
      stops: gradientStops,
    ),
  );
}