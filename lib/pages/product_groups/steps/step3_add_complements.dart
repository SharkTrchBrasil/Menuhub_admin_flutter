import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/variant_option.dart';

import '../../../core/enums/form_status.dart';
import '../cubit/create_complement_cubit.dart';
import '../widgets/add_option_flow.dart';
import '../widgets/complement_copy_list.dart';
import '../widgets/complement_creation_form.dart';
import '../widgets/wizard_footer.dart';
import '../widgets/wizard_header.dart';

// Enum para controlar o modo interno desta tela
enum Step3Mode { choice, create, copy }

class Step3AddComplements extends StatefulWidget {

  const Step3AddComplements({super.key,});

  @override
  State<Step3AddComplements> createState() => _Step3AddComplementsState();
}

class _Step3AddComplementsState extends State<Step3AddComplements> {
  Step3Mode _mode = Step3Mode.choice;

  void _changeMode(Step3Mode newMode) {
    setState(() => _mode = newMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Recomendo usar Scaffold para uma estrutura de tela padrão
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WizardHeader(
              title: "Criar novo grupo",
              currentStep: 3,
              totalSteps: 3,
              onClose: () => Navigator.of(context).pop(),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // ✨ O corpo agora sempre mostra o fluxo de adicionar opção
                    AddOptionFlow(
                      onCancel: () {
                        // Neste contexto, "cancelar" a criação de uma opção
                        // não faz nada, o usuário continua na mesma tela.
                      },
                      onOptionCreated: (option) {
                        // Adiciona a opção criada ao estado do Cubit
                        context.read<CreateComplementGroupCubit>().addComplementOption(option);
                      },
                    ),
                    _buildAddedComplementsList(),
                  ],
                ),
              ),
            ),


            BlocBuilder<CreateComplementGroupCubit, CreateComplementGroupState>(
              builder: (context, state) {
                return WizardFooter(
                  onBack:
                      () => context.read<CreateComplementGroupCubit>().goBack(),
                  // Passamos o estado de loading para o footer
                  isLoading: state.status == FormStatus.loading,
                  continueLabel: "Concluir",
                  // A lógica do onPressed vai aqui
                  onContinue:
                      state.complements.isEmpty
                          ? null
                          : () async {
                            final result =
                                await context
                                    .read<CreateComplementGroupCubit>()
                                    .completeFlowAndGetResult();
                            if (result != null && context.mounted) {
                              Navigator.of(context).pop(result);
                            }
                          },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelBody() {
    switch (_mode) {
      case Step3Mode.choice:
        return _buildChoiceUI();
      case Step3Mode.create:
        return ComplementCreationForm(
          onCancel: () => _changeMode(Step3Mode.choice),
          onOptionCreated: (VariantOption option) {
            // ✨ 2. A LÓGICA AGORA FICA AQUI DENTRO
            // Adiciona a opção ao estado global do Cubit
            context.read<CreateComplementGroupCubit>().addComplementOption(option);
            // E então volta para a tela de escolha
            _changeMode(Step3Mode.choice);
          },
        );
      case Step3Mode.copy:
        return ComplementCopyList(onBack: () => _changeMode(Step3Mode.choice));
    }
  }

  Widget _buildChoiceUI() {
    return Column(
      key: const ValueKey('choice'),
      children: [
        _buildChoiceCard(
          context: context,
          title: "Criar novo complemento",
          subtitle: "Crie um item do zero, definindo nome, preço e foto.",
          icon: Icons.add_circle_outline,
          onTap: () => _changeMode(Step3Mode.create),
        ),
        const SizedBox(height: 16),
        _buildChoiceCard(
          context: context,
          title: "Copiar complemento existente",
          subtitle:
              "Reaproveite produtos ou itens que já existem no seu cardápio.",
          icon: Icons.copy_all_outlined,
          onTap: () => _changeMode(Step3Mode.copy),
        ),
      ],
    );
  }

  // Widget auxiliar para os cards de escolha
  Widget _buildChoiceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddedComplementsList() {
    return BlocBuilder<CreateComplementGroupCubit, CreateComplementGroupState>(
      builder: (context, state) {
        if (state.complements.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 32),
              Text(
                "${state.complements.length} complementos adicionados:",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 150),
                // Limita a altura da lista
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.complements.length,
                  itemBuilder: (context, index) {
                    final complement = state.complements[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.label_important_outline,
                        size: 16,
                      ),
                      title: Text(complement.resolvedName),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed:
                            () => context
                                .read<CreateComplementGroupCubit>()
                                .removeComplementOption(complement),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 24),
            ],
          ),
        );
      },
    );
  }





}
