import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/product_type.dart';
import '../../../../core/responsive_builder.dart';

import '../cubit/product_wizard_cubit.dart';
import '../cubit/product_wizard_state.dart';



class Step1ProductType extends StatelessWidget {
  const Step1ProductType({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900), // Aumentei a largura máxima para o layout lado a lado
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Primeiro, qual o tipo de produto?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Isso nos ajuda a sugerir os campos corretos para o seu item.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),

              BlocBuilder<ProductWizardCubit, ProductWizardState>(
                builder: (context, state) {
                  // ✅ LÓGICA DE LAYOUT RESPONSIVO
                  return ResponsiveBuilder(
                    // Layout para Celular
                    mobileBuilder: (context, constraints) => Column(
                      children: [
                        _buildPreparedCard(context, state),
                        const SizedBox(height: 16),
                        _buildResaleCard(context, state),
                      ],
                    ),
                    // Layout para Desktop/Telas Maiores
                    desktopBuilder: (context, constraints) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildPreparedCard(context, state)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildResaleCard(context, state)),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper para o card de Produção Própria
  Widget _buildPreparedCard(BuildContext context, ProductWizardState state) {
    return _TypeSelectionCard(
      // ✅ TEXTOS REESCRITOS
      title: 'Item de Produção Própria',
      description: 'Ideal para pratos, lanches, bolos e qualquer item que sua cozinha prepara na hora.',
      value: ProductType.PREPARED,
      groupValue: state.productType,
      onChanged: (type) => context.read<ProductWizardCubit>().setProductType(type),
    );
  }

  // Helper para o card de Revenda
  Widget _buildResaleCard(BuildContext context, ProductWizardState state) {
    return _TypeSelectionCard(
      // ✅ TEXTOS REESCRITOS
      title: 'Item de Revenda',
      description: 'Para produtos prontos que você apenas revende, como bebidas, doces e outros itens de prateleira.',
      value: ProductType.INDUSTRIALIZED,
      groupValue: state.productType,
      onChanged: (type) => context.read<ProductWizardCubit>().setProductType(type),
    );
  }
}

// Widget auxiliar para os cards de seleção (sem alterações na sua estrutura)
class _TypeSelectionCard extends StatelessWidget {
  final String title;
  final String description;
  final ProductType value;
  final ProductType groupValue;
  final ValueChanged<ProductType> onChanged;

  const _TypeSelectionCard({
    required this.title,
    required this.description,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(description, style: TextStyle(color: Colors.grey.shade600, height: 1.5)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Radio<ProductType>(
                value: value,
                groupValue: groupValue,
                onChanged: (v) => onChanged(v!),
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}