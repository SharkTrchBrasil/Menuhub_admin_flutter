import 'package:flutter/material.dart';


/// WIDGET: Placeholder para abas sem conteúdo
class PlaceholderSliver extends StatelessWidget {
  final String message;
  const PlaceholderSliver({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(child: Text(message, style: const TextStyle(fontSize: 18))),
    );
  }
}