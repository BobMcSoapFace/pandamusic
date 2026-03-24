import 'package:flutter/material.dart';

enum WindowSize{
  desktop,
  tablet,
  mobile,
}
class Responsive extends StatelessWidget {
  final Widget desktop;
  final Widget? tablet;
  final Widget? mobile;

  static final int _desktopWidth = 1280;
  static final int _tabletWidth = 904;

  const Responsive({super.key, required this.desktop, this.tablet, this.mobile});

  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= _desktopWidth;
  static bool isTablet(BuildContext context) => !isDesktop(context) && MediaQuery.of(context).size.width >= _tabletWidth;
  static bool isMobile(BuildContext context) => !isTablet(context) && !isDesktop(context);
  static WindowSize size(BuildContext context) => isDesktop(context) ? WindowSize.tablet : isTablet(context) ? WindowSize.tablet : WindowSize.mobile;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if(size.width >= _desktopWidth || (tablet == null && mobile == null)){
      return desktop;
    } else if (size.width >= _tabletWidth && tablet != null){
      return tablet!;
    }
    return mobile!;
  }
}