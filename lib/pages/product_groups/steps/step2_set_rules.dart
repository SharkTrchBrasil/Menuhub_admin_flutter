// ✅ ARQUIVO ATUALIZADO: Step2SetRules.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/models/variant.dart';

import '../cubit/create_complement_cubit.dart';
import '../widgets/wizard_footer.dart';

// ✨ 1. Convertido para StatelessWidget
class Step2SetRules extends StatelessWidget {
  const Step2SetRules({super.key});

  @override
  Widget build(BuildContext context) {
    // ✨ 2. Usamos `context.watch` para que a tela se reconstrua quando o estado do Cubit mudar
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
            ResponsiveBuilder.isDesktop(context)
                ? _buildDesktopLayout(context, selectedVariant) // Passa o context
                : _buildMobileLayout(context, selectedVariant), // Passa o context
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

  // --- LAYOUTS RESPONSIVOS ---

  Widget _buildDesktopLayout(BuildContext context, Variant variant) {
    const headerStyle = TextStyle(color: Colors.black54, fontWeight: FontWeight.bold);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Expanded(flex: 2, child: Text("Grupo de complementos", style: headerStyle)),
              const SizedBox(width: 16),
              const Expanded(flex: 2, child: Text("Obrigatoriedade", style: headerStyle)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: Text("Qtd. Mínima", textAlign: TextAlign.center, style: headerStyle)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: Text("Qtd. Máxima", textAlign: TextAlign.center, style: headerStyle)),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 2, child: _buildGroupInfoCell(variant)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildRequiredOptionalSelector(context)), // Passa o context
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildQuantityStepper(context, isMin: true)), // Passa o context
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildQuantityStepper(context, isMin: false)), // Passa o context
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, Variant variant) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildGroupInfoCell(variant),
            const Divider(height: 24),
            _buildMobileRuleRow("Obrigatoriedade", _buildRequiredOptionalSelector(context)),
            const SizedBox(height: 16),
            _buildMobileRuleRow("Quantidade Mínima", _buildQuantityStepper(context, isMin: true)),
            const SizedBox(height: 16),
            _buildMobileRuleRow("Quantidade Máxima", _buildQuantityStepper(context, isMin: false)),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE CÉLULAS E COMPONENTES ---

  Widget _buildGroupInfoCell(Variant variant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(variant.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        if (variant.productLinks != null && variant.productLinks!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            "Disponível em: ${variant.productLinks!.length} produtos",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildMobileRuleRow(String label, Widget control) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        SizedBox(
          width: 150,
          child: control,
        ),
      ],
    );
  }

  // ✨ 3. Todos os widgets de formulário agora leem e escrevem DIRETAMENTE no Cubit
  Widget _buildRequiredOptionalSelector(BuildContext context) {
    final cubit = context.read<CreateComplementGroupCubit>();
    final state = cubit.state;

    return DropdownButtonFormField<bool>(
      value: state.isRequired, // Lê do estado do Cubit
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
      items: const [
        DropdownMenuItem(value: false, child: Text("Opcional")),
        DropdownMenuItem(value: true, child: Text("Obrigatório")),
      ],
      onChanged: (newSelection) {
        if (newSelection == null) return;
        bool newIsRequired = newSelection;
        int newMinQty = state.minQty;
        int newMaxQty = state.maxQty;

        if (newIsRequired && newMinQty < 1) {
          newMinQty = 1;
          if (newMaxQty < 1) newMaxQty = 1;
        }
        if (!newIsRequired) {
          newMinQty = 0;
        }

        // Escreve as novas regras no Cubit
        cubit.updateRulesForCopiedGroup(isRequired: newIsRequired, min: newMinQty, max: newMaxQty);
      },
    );
  }

  Widget _buildQuantityStepper(BuildContext context, {required bool isMin}) {
    final cubit = context.read<CreateComplementGroupCubit>();
    final state = cubit.state;

    int value = isMin ? state.minQty : state.maxQty;

    return Container(
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.remove, size: 20),
            onPressed: value > (isMin ? 0 : state.minQty)
                ? () {
              int newMin = state.minQty;
              int newMax = state.maxQty;
              bool newIsRequired = state.isRequired;

              if (isMin) {
                newMin--;
                if (newMin == 0) newIsRequired = false;
              } else {
                newMax--;
              }
              cubit.updateRulesForCopiedGroup(isRequired: newIsRequired, min: newMin, max: newMax);
            }
                : null,
          ),
          Text(value.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.add, size: 20),
            onPressed: () {
              int newMin = state.minQty;
              int newMax = state.maxQty;
              bool newIsRequired = state.isRequired;

              if (isMin) {
                if (value < state.maxQty) {
                  newMin++;
                  if (newMin > 0) newIsRequired = true;
                }
              } else {
                newMax++;
              }
              cubit.updateRulesForCopiedGroup(isRequired: newIsRequired, min: newMin, max: newMax);
            },
          ),
        ],
      ),
    );
  }
}