import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';

import '../ConstData/typography.dart';

class AppPageHeader extends StatelessWidget {
  const AppPageHeader({super.key, required this.title, required this.actions, this.canPop = true});

  final String title;
  final List<Widget> actions;
  final bool canPop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          Row(
            children: [
              if(canPop ) ... [
                BackButton(),
                const SizedBox(width: 8),
              ],

              Expanded(
                child: Text(
                  title,
    style: TextStyle(fontFamily: 'Jost-SemiBold',fontSize: 20,fontWeight: FontWeight.bold),overflow: TextOverflow.ellipsis
                ),
              ),
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
