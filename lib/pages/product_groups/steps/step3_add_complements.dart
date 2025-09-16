// lib/pages/product_groups/views/step3_add_complements.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/models/variant_option.dart';
import 'package:totem_pro_admin/pages/product_groups/cubit/create_complement_cubit.dart';
import 'package:totem_pro_admin/pages/product_groups/widgets/complement_copy_list.dart';
import 'package:totem_pro_admin/pages/product_groups/widgets/complement_creation_form.dart';
import 'package:totem_pro_admin/pages/product_groups/widgets/wizard_footer.dart';

import '../widgets/create_complement_panel.dart';

class Step3AddComplements extends StatelessWidget {
  const Step3AddComplements({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<CreateComplementGroupCubit>();
    final state = cubit.state;

    return Scaffold(

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Cabeçalho com o título dinâmico e os botões de ação
            _buildHeader(context, state.groupName),
            const SizedBox(height: 32),
            // ✅ Lista de complementos já adicionados
            _buildComplementsList(context),
          ],
        ),
      ),
      bottomNavigationBar: WizardFooter(
        onBack: () => cubit.goBack(),
        isLoading: state.status == FormStatus.loading,
        continueLabel: "Concluir",
        // Botão só fica ativo se tiver pelo menos 1 complemento
        onContinue: state.complements.isEmpty
            ? null
            : () async {
          final result = await cubit.completeFlowAndGetResult();
          if (result != null && context.mounted) {
            Navigator.of(context).pop(result);
          }
        },
      ),
    );
  }

  // --- Widgets Auxiliares da Tela ---

  /// Constrói o cabeçalho com título e botões
  Widget _buildHeader(BuildContext context, String groupName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Agora, adicione complementos ao grupo "$groupName"',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ResponsiveBuilder(
          mobileBuilder: (ctx, constr) => Column(
            children: [
              _buildActionButton(
                context: context,
                label: "Criar novo complemento",
                icon: Icons.add_circle_outline,
                onTap: () => _showCreationPanel(context),
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                context: context,
                label: "Copiar complemento",
                icon: Icons.copy_all_outlined,
                onTap: () => _showCopyPanel(context),
              ),
            ],
          ),
          desktopBuilder: (ctx, constr) => Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context: context,
                  label: "Criar novo complemento",
                  icon: Icons.add_circle_outline,
                  onTap: () => _showCreationPanel(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  context: context,
                  label: "Copiar complemento",
                  icon: Icons.copy_all_outlined,
                  onTap: () => _showCopyPanel(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// O botão de ação reutilizável
  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.centerLeft,
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }

  /// Constrói a lista de complementos adicionados
  Widget _buildComplementsList(BuildContext context) {
    // Usa um BlocBuilder para reconstruir apenas a lista quando necessário
    return BlocBuilder<CreateComplementGroupCubit, CreateComplementGroupState>(
      builder: (context, state) {
        if (state.complements.isEmpty) {
          // Mostra um estado vazio se não houver complementos
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48.0),
              child: Text(
                "Nenhum complemento adicionado ainda.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Adicionados:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              itemCount: state.complements.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final complement = state.complements[index];
                return _AddedComplementCard(complement: complement);
              },
            ),
          ],
        );
      },
    );
  }

  // --- Funções para Abrir os Painéis (Bottom Sheets) ---
  // ✅ NOVA FUNÇÃO PARA CHAMAR O PAINEL DE CRIAÇÃO
  Future<void> _showCreationPanel(BuildContext context) async {
    final newOption = await showModalBottomSheet<VariantOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Para que o DraggableScrollableSheet controle a cor e bordas
      builder: (_) => const CreateComplementPanel(),
    );

    // Se o painel retornou um complemento, adiciona ao cubit principal
    if (newOption != null && context.mounted) {
      context.read<CreateComplementGroupCubit>().addComplementOption(newOption);
    }
  }


  void _showCopyPanel(BuildContext context) {
    // Usa o `showModalBottomSheet` para a lista de cópia
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<CreateComplementGroupCubit>(),
          child: ComplementCopyList(
            onBack: () => Navigator.of(context).pop(),
          ),
        );
      },
    );
  }
}

// ✅ WIDGET DEDICADO PARA O CARD DE COMPLEMENTO ADICIONADO
class _AddedComplementCard extends StatelessWidget {
  final VariantOption complement;
  const _AddedComplementCard({required this.complement});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Imagem
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 48,
                height: 48,
                color: Colors.grey.shade200,
                child: complement.image?.url != null
                    ? Image.network(complement.image!.url!, fit: BoxFit.cover)
                    : const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            // Nome e Preço
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(complement.resolvedName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    "Preço: R\$ ${(complement.price_override ??  0 / 100).toStringAsFixed(2)}",
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  )
                ],
              ),
            ),
            // Botão de remover
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                context.read<CreateComplementGroupCubit>().removeComplementOption(complement);
              },
              tooltip: "Remover complemento",
            ),
          ],
        ),
      ),
    );
  }
}