import 'package:flutter/material.dart';

import '../../../core/responsive_builder.dart';


/// WIDGET: Cabeçalho da página (Título e descrição)
class PageHeader extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    final bool isMobile = ResponsiveBuilder.isMobile(context);
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveBuilder.isMobile(context) ? 14 : 24.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Cardápio',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.lightbulb_outline),
                      onPressed: () {}),
                  IconButton(icon: const Icon(Icons.bar_chart), onPressed: () {}),
                  IconButton(
                      icon: const Icon(Icons.settings_outlined), onPressed: () {}),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Defina quais os itens seus clientes podem pedir pelo iFood',
            style: TextStyle(fontSize: 15, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
