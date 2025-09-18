// ✅ ARQUIVO ATUALIZADO: Step2SetRules.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/models/variant.dart';

import '../cubit/create_complement_cubit.dart';
import '../widgets/wizard_footer.dart';


class Step2SetRules extends StatelessWidget {
  const Step2SetRules({super.key});

  @override
  Widget build(BuildContext context) {

    final cubit = context.watch<CreateComplementGroupCubit>();
    final state = cubit.state;
    final selectedVariant = state.selectedVariantToCopy;

    if (selectedVariant == null) {
      return const Center(child: Text("Erro: Nenhum grupo selecionado para copiar."));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Agora, defina a regra do grupo",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            const SizedBox(height: 24),
            _buildRulesSection(context),
          ],
        ),
      ),
      bottomNavigationBar: WizardFooter(
        onBack: cubit.goBack,
        continueLabel: "Concluir",
        // ✨ A ação de continuar agora é mais simples
        onContinue: () async {
          // As regras já estão salvas no Cubit, então só precisamos finalizar
          final result = await cubit.completeFlowAndGetResult();
          if (result != null && context.mounted) {
            Navigator.of(context).pop(result);
          }
        },
      ),
    );
  }



  Widget _buildRulesSection(BuildContext context) {
    // ✅ Os valores agora são lidos DIRETAMENTE do Cubit via context.watch
    final cubit = context.watch<CreateComplementGroupCubit>();
    final state = cubit.state;

    final dropdown = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormLabel("Este grupo é obrigatório ou opcional?"),
        DropdownButtonFormField<bool>(
          value: state.isRequired, // Lendo do Cubit
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: false, child: Text("Opcional")),
            DropdownMenuItem(value: true, child: Text("Obrigatório")),
          ],
          onChanged: (newSelection) {
            if (newSelection == null) return;
            // Lógica de sincronia
            int newMinQty = state.minQty;
            int newMaxQty = state.maxQty;
            if (newSelection) { // se for obrigatório
              if (newMinQty < 1) newMinQty = 1;
              if (newMaxQty < 1) newMaxQty = 1;
            } else { // se for opcional
              newMinQty = 0;
            }
            // ✅ `onChanged` agora atualiza o Cubit
            cubit.updateRulesForCopiedGroup(
              isRequired: newSelection,
              min: newMinQty,
              max: newMaxQty,
            );
          },
        ),
      ],
    );

    // Lógica para o stepper de "Quantidade Mínima"
    final minStepper = _buildQuantityStepper(
      label: "Qtd. mínima",
      value: state.minQty,
      // Botão de diminuir: só funciona se minQty > 0
      onDecrement: state.minQty > 0
          ? () {
        final newMin = state.minQty - 1;
        cubit.updateRulesForCopiedGroup(
          min: newMin,
          isRequired: newMin > 0, // Sincroniza o "obrigatório"
          max: state.maxQty,
        );
      }
          : null, // Desabilita o botão
      // Botão de aumentar: só funciona se minQty < maxQty
      onIncrement: state.minQty < state.maxQty
          ? () {
        final newMin = state.minQty + 1;
        cubit.updateRulesForCopiedGroup(
          min: newMin,
          isRequired: newMin > 0, // Sincroniza o "obrigatório"
          max: state.maxQty,
        );
      }
          : null, // Desabilita o botão
    );

    // Lógica para o stepper de "Quantidade Máxima"
    final maxStepper = _buildQuantityStepper(
      label: "Qtd. máxima",
      value: state.maxQty,
      // Botão de diminuir: só funciona se maxQty > minQty
      onDecrement: state.maxQty > state.minQty
          ? () => cubit.updateRulesForCopiedGroup(
        min: state.minQty,
        max: state.maxQty - 1,
        isRequired: state.isRequired,
      )
          : null, // Desabilita o botão
      // Botão de aumentar: sempre funciona
      onIncrement: () => cubit.updateRulesForCopiedGroup(
        min: state.minQty,
        max: state.maxQty + 1,
        isRequired: state.isRequired,
      ),
    );

    if (ResponsiveBuilder.isDesktop(context)) {
      // Layout desktop
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: dropdown),
          const SizedBox(width: 16),
          Expanded(flex: 1, child: minStepper),
          const SizedBox(width: 16),
          Expanded(flex: 1, child: maxStepper),
        ],
      );
    } else {
      // Layout mobile
      return Column(
        children: [
          dropdown,
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(child: minStepper),
              const SizedBox(width: 44),
              Flexible(child: maxStepper),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildFormLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildQuantityStepper({
    required String label,
    required int value,
    required VoidCallback? onDecrement, // Callback para o botão "-"
    required VoidCallback? onIncrement, // Callback para o botão "+"
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // O botão fica desabilitado se o callback for nulo
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: onDecrement,
              ),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // O botão fica desabilitado se o callback for nulo
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: onIncrement,
              ),
            ],
          ),
        ),
      ],
    );
  }
}