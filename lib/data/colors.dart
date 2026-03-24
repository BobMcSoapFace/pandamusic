

import 'package:flutter/material.dart';

abstract class AppColor {
  static final Color blue = Color(0xFF40DFEF);
  static final Color red = Color(0xFFE78EA9);
  static final Color green = Color(0xFFB9F8D3);
  static final Color yellow = Color(0xFFFFFBE7);
  
  static ColorScheme scheme(BuildContext context) => Theme.of(context).colorScheme;
}