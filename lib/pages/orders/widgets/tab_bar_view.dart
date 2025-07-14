// lib/pages/orders/widgets/_tab_bar_view.dart
import 'package:flutter/material.dart';


class OrderTabBarView extends StatelessWidget {
  final TabController tabController;
  final int currentTabIndex;

  const OrderTabBarView({
    Key? key,
    required this.tabController,
    required this.currentTabIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      // Indicator for the active tab (the red line/underline)
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 3.0, // Thickness of the underline
          color: Colors.red, // Color of the underline
        ),
        // Optional: adjust insets if needed
        insets: EdgeInsets.symmetric(horizontal: 16.0),
      ),
      // Color of the label text for the selected tab
      labelColor: Colors.red,
      // Color of the label text for unselected tabs
      unselectedLabelColor: Colors.black,
      // Ensure splash and highlight colors are handled if you click the tab itself
      overlayColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.red.withOpacity(0.1); // Subtle splash on press
          }
          return null; // Defer to the widget's default.
        },
      ),
      tabs: const [
        Tab(text: 'Agora'),
        Tab(text: 'Agendados'),
      ],
    );
  }
}