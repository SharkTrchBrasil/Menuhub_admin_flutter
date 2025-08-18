// dentro de 'dashboard_widgets.dart' ou um novo arquivo de widgets

import 'package:flutter/material.dart';

import '../../../ConstData/colorprovider.dart';
import '../../../ConstData/staticdata.dart';
import '../../../ConstData/typography.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final ColorNotifire notifire;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.notifire,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: notifire.getGry700_300Color),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: notifire.getGry500_600Color,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Typographyy.heading6.copyWith(color: notifire.getTextColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Typographyy.bodyLargeMedium.copyWith(color: notifire.getGry500_600Color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}