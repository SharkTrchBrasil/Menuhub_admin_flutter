import 'package:flutter/material.dart';


class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    required this.mobileBuilder,
    required this.desktopBuilder,
    Key? key,
  }) : super(key: key);

  final Widget Function(
      BuildContext context,
      BoxConstraints constraints,
      ) mobileBuilder;

  final Widget Function(
      BuildContext context,
      BoxConstraints constraints,
      ) desktopBuilder;

  // Dispositivos pequenos (celulares)
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  // Dispositivos grandes (notebooks e desktops)
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768; // ✅ Mudei para 768

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 768) { // ✅ Mudei para 768
          return desktopBuilder(context, constraints);
        } else {
          return mobileBuilder(context, constraints);
        }
      },
    );
  }
}