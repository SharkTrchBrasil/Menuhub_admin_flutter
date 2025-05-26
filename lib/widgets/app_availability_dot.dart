import 'package:flutter/material.dart';

class AppAvailabilityDot extends StatelessWidget {
  const AppAvailabilityDot({super.key, required this.available});

  final bool available;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: available ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
