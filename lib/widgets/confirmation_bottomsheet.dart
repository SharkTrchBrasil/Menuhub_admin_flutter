import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import 'ds_primary_button.dart';

class ConfirmationBottomSheet extends StatelessWidget {
  final String title;
  final String message;
  final String cancelButtonText;
  final String confirmButtonText;

  const ConfirmationBottomSheet({
    super.key,
    required this.title,
    required this.message,
    required this.cancelButtonText,
    required this.confirmButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com botão de fechar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF151515),
                  ),
                ),
                // ✅ RETORNA `false` AO FECHAR NO 'X'
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(false),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mensagem
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 24),

            // Rodapé com botões
            Row(
              children: [
                // Botão Cancelar
                Expanded(
                  child: DsButton(
                    style: DsButtonStyle.secondary,
                    requiresConnection: false,


                    onPressed: () => Navigator.of(context).pop(false),

                    label: cancelButtonText,
                  ),
                ),
                const SizedBox(width: 12),

                // Botão Confirmar
                Expanded(
                  child: DsButton(

                      // Ação de remover grupo
                      onPressed: () => Navigator.of(context).pop(true),

                  label:
                    confirmButtonText,
                  ),
                ),













              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}








