import 'package:flutter/material.dart';

import 'package:totem_pro_admin/core/extensions/extensions.dart';

class AppPageHeader extends StatelessWidget {
  const AppPageHeader({super.key, required this.title, required this.actions, this.canPop = true, this.tag});

  final String title;
  final List<Widget> actions;
  final bool canPop;
  final Widget? tag;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              if(canPop && !context.isSmallScreen) ... [
                BackButton(),
                const SizedBox(width: 8),
              ],
              if(context.isSmallScreen) ...[
                DrawerButton(),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff2a2a3b),
                  ),
                ),
              ),
              if (tag != null) ... [
                const SizedBox(width: 8),
                tag!,
              ],
              if(!context.isSmallScreen)
                Row(
                  spacing: 16,
                  children: actions,
                )
            ],
          ),
          if(context.isSmallScreen)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                spacing: 16,
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions,
              ),
            )
        ],
      ),
    );
  }
}
