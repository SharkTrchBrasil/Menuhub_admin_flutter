import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totem_pro_admin/ConstData/typography.dart';
import '../../core/menu_app_controller.dart';
import '../../core/responsive_builder.dart';

class BasePage extends StatelessWidget {
  final Widget Function(BuildContext context) mobileBuilder;
  final Widget Function(BuildContext context) desktopBuilder;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Widget? mobileBottomNavigationBar;
  final PreferredSizeWidget? desktopAppBar;
  final PreferredSizeWidget? mobileAppBar;
  final Widget? desktopDrawer;

  final Widget? floatingActionButton;
  final Widget? bottomSheet;
  final Color ? backgroundColor;

  const BasePage({
    super.key,
    required this.mobileBuilder,
    required this.desktopBuilder,
    this.scaffoldKey,
    this.mobileBottomNavigationBar,
    this.desktopAppBar,
    this.desktopDrawer,
    this.floatingActionButton,
    this.mobileAppBar,
    this.bottomSheet,
    this.backgroundColor,
  });



  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBuilder.isMobile(context);
    final isDesktop = ResponsiveBuilder.isDesktop(context);

    return SafeArea(
      child: Scaffold(
      // backgroundColor: backgroundColor,
      key: key,

        drawer: isDesktop ? desktopDrawer : null,
        appBar: isDesktop ? desktopAppBar : mobileAppBar,
        body: isMobile ? mobileBuilder(context) : desktopBuilder(context),
        bottomNavigationBar: isMobile ? mobileBottomNavigationBar : null,
        floatingActionButton: isMobile ? floatingActionButton : null,
        bottomSheet: isMobile ? bottomSheet:null
      ),
    );
  }
}
