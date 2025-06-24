import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';

class FixedHeader extends StatelessWidget {
  final String title;
  final String? newItemRoute;
  final VoidCallback? onAddPressed;
  final List<Widget>? actions;

  const FixedHeader({
    super.key,
    required this.title,
    this.newItemRoute,
    this.onAddPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,

            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              if (actions != null) ...actions!,
              const SizedBox(width: 10),


            ],
          ),
        ],
      ),
    );
  }
}
