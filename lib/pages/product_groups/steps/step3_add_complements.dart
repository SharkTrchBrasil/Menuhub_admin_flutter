
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/models/variant_option.dart';
import 'package:totem_pro_admin/pages/product_groups/cubit/create_complement_cubit.dart';
import 'package:totem_pro_admin/pages/product_groups/widgets/complement_copy_list.dart';
import 'package:totem_pro_admin/pages/product_groups/widgets/create_complement_panel.dart';
import 'package:totem_pro_admin/pages/product_groups/widgets/wizard_footer.dart';
import 'package:totem_pro_admin/widgets/app_image_form_field.dart';

import '../widgets/editable_complement_card.dart';

class Step3AddComplements extends StatelessWidget {
  const Step3AddComplements({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<CreateComplementGroupCubit>();
    final state = cubit.state;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14.0,),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, state.groupName),
            const SizedBox(height: 32),
            _buildComplementsList(context),
          ],
        ),
      ),
      bottomNavigationBar: WizardFooter(
        onBack: () => cubit.goBack(),
        isLoading: state.status == FormStatus.loading,
        continueLabel: "Concluir",
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

  Widget _buildHeader(BuildContext context, String groupName) { /* ... (sem alterações) ... */
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
              _buildActionButton(context: context, label: "Criar novo complemento", icon: Icons.add_circle_outline, onTap: () => _showCreationPanel(context)),
              const SizedBox(height: 12),
              _buildActionButton(context: context, label: "Copiar complemento", icon: Icons.copy_all_outlined, onTap: () => _showCopyPanel(context)),
            ],
          ),
          desktopBuilder: (ctx, constr) => Row(
            children: [
              Expanded(child: _buildActionButton(context: context, label: "Criar novo complemento", icon: Icons.add_circle_outline, onTap: () => _showCreationPanel(context))),
              const SizedBox(width: 16),
              Expanded(child: _buildActionButton(context: context, label: "Copiar complemento", icon: Icons.copy_all_outlined, onTap: () => _showCopyPanel(context))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({ required BuildContext context, required String label, required IconData icon, required VoidCallback onTap}) { /* ... (sem alterações) ... */
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16), alignment: Alignment.centerLeft, side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildComplementsList(BuildContext context) {
    return BlocBuilder<CreateComplementGroupCubit, CreateComplementGroupState>(
      builder: (context, state) {
        if (state.complements.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48.0),
              child: Text("Nenhum complemento adicionado ainda.", style: TextStyle(color: Colors.grey)),
            ),
          );
        }
        return ListView.separated(
          itemCount: state.complements.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final complement = state.complements[index];

            return EditableComplementCard(
              key: ValueKey(complement.clientId), // Chave para o Flutter identificar o item
              complement: complement,
              index: index,
            );
          },
        );
      },
    );
  }

  Future<void> _showCreationPanel(BuildContext context) async { /* ... (sem alterações) ... */
    final newOption = await showModalBottomSheet<VariantOption>(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const CreateComplementPanel());
    if (newOption != null && context.mounted) {
      context.read<CreateComplementGroupCubit>().addComplementOption(newOption);
    }
  }

  void _showCopyPanel(BuildContext context) { /* ... (sem alterações) ... */
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) {
      return BlocProvider.value(
        value: context.read<CreateComplementGroupCubit>(),
        child: ComplementCopyList(onBack: () => Navigator.of(context).pop()),
      );
    });
  }
}

