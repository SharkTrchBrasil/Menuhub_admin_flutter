import 'package:flutter/material.dart';
class WizardStepLayout extends StatelessWidget {

  final String sectionTitle;
  final String largeTitle;
  final String description;
  final Widget child;


  const WizardStepLayout({


    required this.largeTitle,
    required this.description,
    required this.child,

    required this.sectionTitle,
  });

  @override
  Widget build(BuildContext context) {

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      margin: const EdgeInsets.all(16),
      padding:  EdgeInsets.all(isMobile ?12 : 32),
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(
            sectionTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 12),
          ),

          const SizedBox(height: 12),
          Text(
            largeTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // --- CONTEÚDO (FORMULÁRIO) ---
          Expanded(child: child),



        ],
      ),
    );
  }
}