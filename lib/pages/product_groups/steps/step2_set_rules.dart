import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/models/variant.dart';

import '../cubit/create_complement_cubit.dart';
import '../widgets/wizard_footer.dart';
import '../widgets/wizard_header.dart';

class Step2SetRules extends StatefulWidget {
  const Step2SetRules({super.key});

  @override
  State<Step2SetRules> createState() => _Step2SetRulesState();
}

class _Step2SetRulesState extends State<Step2SetRules> {
  late bool _isRequired;
  late int _minQty;
  late int _maxQty;

  @override
  void initState() {
    super.initState();
    final state = context.read<CreateComplementGroupCubit>().state;
    _isRequired = state.isRequired;
    _minQty = state.minQty;
    _maxQty = state.maxQty;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateComplementGroupCubit>();
    final selectedVariant = cubit.state.selectedVariantToCopy;

    if (selectedVariant == null) {
      return const Center(child: Text("Erro: Nenhum grupo selecionado para copiar."));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WizardHeader(
              title: "Copiar grupo",
              currentStep: 2,
              totalSteps: 2,
              onClose: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
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
                        ? _buildDesktopLayout(selectedVariant)
                        : _buildMobileLayout(selectedVariant),
                  ],
                ),
              ),
            ),
            WizardFooter(
              onBack: cubit.goBack,
              continueLabel: "Concluir",
              onContinue: () async {
                cubit.updateRulesForCopiedGroup(isRequired: _isRequired, min: _minQty, max: _maxQty);
                final result = await cubit.completeFlowAndGetResult();
                if (result != null && mounted) {
                  Navigator.of(context).pop(result);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- LAYOUTS RESPONSIVOS ---

  Widget _buildDesktopLayout(Variant variant) {
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
              Expanded(flex: 2, child: _buildRequiredOptionalSelector()),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildQuantityStepper(isMin: true)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildQuantityStepper(isMin: false)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Variant variant) {
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
            _buildMobileRuleRow("Obrigatoriedade", _buildRequiredOptionalSelector()),
            const SizedBox(height: 16),
            _buildMobileRuleRow("Quantidade Mínima", _buildQuantityStepper(isMin: true)),
            const SizedBox(height: 16),
            _buildMobileRuleRow("Quantidade Máxima", _buildQuantityStepper(isMin: false)),
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

  Widget _buildRequiredOptionalSelector() {
    return DropdownButtonFormField<bool>(
      value: _isRequired,
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
        setState(() {
          _isRequired = newSelection;
          if (_isRequired && _minQty < 1) {
            _minQty = 1;
            if (_maxQty < 1) _maxQty = 1;
          }
          if (!_isRequired) {
            _minQty = 0;
          }
        });
      },
    );
  }

  Widget _buildQuantityStepper({required bool isMin}) {
    int value = isMin ? _minQty : _maxQty;

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
            onPressed: value > (isMin ? 0 : _minQty)
                ? () => setState(() {
              if (isMin) {
                _minQty--;
                // ✨ LÓGICA DE SINCRONIA ATUALIZADA AQUI ✨
                // Se a quantidade mínima voltar para 0, o grupo se torna opcional.
                if (_minQty == 0) {
                  _isRequired = false;
                }
              } else {
                _maxQty--;
              }
            })
                : null,
          ),
          Text(value.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.add, size: 20),
            onPressed: () => setState(() {
              if (isMin) {
                if(value < _maxQty) {
                  _minQty++;
                  // ✨ LÓGICA DE SINCRONIA ATUALIZADA AQUI ✨
                  // Se a quantidade mínima for maior que 0, o grupo se torna obrigatório.
                  if (_minQty > 0) {
                    _isRequired = true;
                  }
                }
              } else {
                _maxQty++;
              }
            }),
          ),
        ],
      ),
    );
  }
}