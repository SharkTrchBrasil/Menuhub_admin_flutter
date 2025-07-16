import 'package:flutter/material.dart';

class SubscriptionWarningInline extends StatelessWidget {
  final String? message;
  final VoidCallback? onRenew;

  const SubscriptionWarningInline({
    super.key,
    this.message,
    this.onRenew,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message ?? 'Sua assinatura está vencida.',
              style: const TextStyle(color: Colors.red),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: onRenew,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Renovar'),
          ),
        ],
      ),
    );
  }
}
