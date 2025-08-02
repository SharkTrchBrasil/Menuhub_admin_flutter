import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/store_setup-state.dart';
import '../cubit/store_setup_cubit.dart';

class TaxIdStep extends StatelessWidget {
  const TaxIdStep({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos o watch aqui para que a UI reconstrua quando a seleção mudar
    final selectedType = context.watch<StoreSetupCubit>().state.taxIdType;

    return Column(
      // O conteúdo principal é o Row com as duas opções
      children: [
        Row(
          children: [
            // Opção 1: CNPJ
            Expanded(
              child: _SelectableCard(
                label: 'Pessoa Jurídica',
                icon: Icons.business_center,
                isSelected: selectedType == TaxIdType.cnpj,
                onTap: () {
                  context.read<StoreSetupCubit>().setTaxIdType(TaxIdType.cnpj);
                },
              ),
            ),
            const SizedBox(width: 16), // Espaçamento entre os cards

            // Opção 2: CPF
            Expanded(
              child: _SelectableCard(
                label: 'Pessoa Física',
                icon: Icons.person,
                isSelected: selectedType == TaxIdType.cpf,
                onTap: () {
                  context.read<StoreSetupCubit>().setTaxIdType(TaxIdType.cpf);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =======================================================================
// WIDGET REUTILIZÁVEL PARA O CARD SELECIONÁVEL
// =======================================================================

class _SelectableCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // A cor da borda muda com base na seleção
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.grey.shade300,
            width: isSelected ? 2.0 : 1.0,
          ),
          // Um fundo sutil para o card
          color: isSelected ? colorScheme.primary.withOpacity(0.05) : Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? colorScheme.primary : Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? colorScheme.primary : Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}