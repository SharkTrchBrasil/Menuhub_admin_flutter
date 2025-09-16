import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/responsive_builder.dart';
import '../cubit/create_complement_cubit.dart';
import '../widgets/wizard_footer.dart';


class Step2GroupDetails extends StatefulWidget {
  final GroupType groupType;

  const Step2GroupDetails({super.key, required this.groupType});

  @override
  State<Step2GroupDetails> createState() => _Step2GroupDetailsState();
}

class _Step2GroupDetailsState extends State<Step2GroupDetails> {
  final _formKey = GlobalKey<FormState>();

  // ✅ O TextEditingController ainda é útil para gerenciar o campo de texto
  late final TextEditingController _nameController;



  @override
  void initState() {
    super.initState();
    // ✅ Inicializa o controller com o valor que JÁ ESTÁ no Cubit
    _nameController = TextEditingController(
      text: context
          .read<CreateComplementGroupCubit>()
          .state
          .groupName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // ✅ A função de submit continua a mesma, mas agora os dados já estão salvos no Cubit.
      // Esta chamada serve para avançar para o próximo passo do wizard.
      final state = context
          .read<CreateComplementGroupCubit>()
          .state;
      context.read<CreateComplementGroupCubit>().setGroupDetails(
        name: state.groupName,
        isRequired: state.isRequired,
        min: state.minQty,
        max: state.maxQty,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Usamos `context.watch` para que a UI se reconstrua com as mudanças do Cubit
    final cubit = context.watch<CreateComplementGroupCubit>();
    final state = cubit.state;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveBuilder.isMobile(context) ? 14 : 24.0,

        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              const Text(
                "Agora, defina o grupo e suas informações principais",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              if (widget.groupType == GroupType.specifications ||
                  widget.groupType == GroupType.disposables)
                _buildRecommendations(),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormLabel("Nome do grupo*"),
                  TextFormField(
                    controller: _nameController,
                    // ✅ `onChanged` agora atualiza o Cubit em tempo real
                    onChanged: (value) => cubit.groupNameChanged(value),
                    decoration: const InputDecoration(
                      hintText: "Ex: Ingredientes extras do lanche",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value
                          .trim()
                          .isEmpty) {
                        return "O nome do grupo é obrigatório.";
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildRulesSection(), // Este widget agora também lerá do Cubit
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: WizardFooter(
        onBack: () => context.read<CreateComplementGroupCubit>().goBack(),
        onContinue: _submit,
      ),
    );
  }

  Widget _buildFormLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildRulesSection() {
    // ✅ Os valores agora são lidos DIRETAMENTE do Cubit via context.watch
    final cubit = context.watch<CreateComplementGroupCubit>();
    final state = cubit.state;

    // As variáveis locais foram substituídas por `state.isRequired`, `state.minQty`, etc.
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
            cubit.rulesChanged(
                isRequired: newSelection, minQty: newMinQty, maxQty: newMaxQty);
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
        cubit.rulesChanged(
          minQty: newMin,
          isRequired: newMin > 0, // Sincroniza o "obrigatório"
        );
      }
          : null, // Desabilita o botão
      // Botão de aumentar: só funciona se minQty < maxQty
      onIncrement: state.minQty < state.maxQty
          ? () {
        final newMin = state.minQty + 1;
        cubit.rulesChanged(
          minQty: newMin,
          isRequired: newMin > 0, // Sincroniza o "obrigatório"
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
          ? () => cubit.rulesChanged(maxQty: state.maxQty - 1)
          : null, // Desabilita o botão
      // Botão de aumentar: sempre funciona
      onIncrement: () => cubit.rulesChanged(maxQty: state.maxQty + 1),
    );


    if (ResponsiveBuilder.isDesktop(context)) {
      // ... layout desktop (sem alterações na lógica)
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
      // ... layout mobile (sem alterações na lógica)
      return Column(
        children: [
          dropdown,
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(child: minStepper),
              SizedBox(width: 44,),
              Flexible(child: maxStepper),
            ],
          ),
        ],
      );
    }
  }


  Widget _buildRecommendations() {
    // Define quais recomendações mostrar com base no tipo
    final recommendations =
    widget.groupType == GroupType.specifications
        ? ["Ponto da carne", "Tamanho"]
        : ["Deseja descartáveis?"];

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recomendações inteligentes",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children:


            recommendations.map((rec) {
              return ActionChip(
                label: Text(rec),

                // ✅ CORREÇÃO APLICADA AQUI
                onPressed: () {
                  // 1. Atualiza o campo de texto para o usuário ver
                  _nameController.text = rec;
                  _nameController.selection = TextSelection.fromPosition(TextPosition(offset: _nameController.text.length));


                  // 2. Notifica o Cubit sobre a mudança para que o estado seja salvo
                  context.read<CreateComplementGroupCubit>().groupNameChanged(rec);
                },
              );
            }).toList(),




          ),
        ],
      ),
    );
  }


  // DENTRO DA CLASSE _Step2GroupDetailsState

// ✅ VERSÃO REATORADA E SIMPLIFICADA
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

