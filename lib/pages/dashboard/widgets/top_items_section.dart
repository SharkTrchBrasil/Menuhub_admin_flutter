import 'package:flutter/material.dart';
import 'package:totem_pro_admin/pages/dashboard/widgets/top_product_card.dart';

import '../../../ConstData/colorprovider.dart';
import '../../../ConstData/typography.dart';
import '../../../models/dashboard_data.dart';
import 'empty_state.dart';

class TopItemsSection extends StatelessWidget {
  // Parâmetros que a tornam reutilizável
  final String title;
  final List<TopItem> items;
  final String emptyStateMessage;
  final ColorNotifire notifire;

  const TopItemsSection({
    super.key,
    required this.title,
    required this.items,
    required this.emptyStateMessage,
    required this.notifire,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Typographyy.heading5.copyWith(color: notifire.getTextColor),
        ),
        const SizedBox(height: 16),

        if (items.isEmpty)
          EmptyStateWidget(
            icon: Icons.sentiment_dissatisfied_outlined,
            title: "Nenhum dado encontrado",
            message: emptyStateMessage,
            notifire: notifire,
          )
        else
          SizedBox(
            height: 240,
            child: ListView.separated(
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final currentItem = items[index];
                return SizedBox(
                  width: 280,
                  child: TopItemCard(
                    product: currentItem,
                    notifire: notifire,
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 16),
            ),
          ),
      ],
    );
  }

}