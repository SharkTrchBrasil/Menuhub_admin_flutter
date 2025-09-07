import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/models/product_variant_link.dart';


import '../../../../widgets/mobile_mockup.dart';
import '../../product_edit/widgets/variant_link_card.dart';
import '../../product_groups/helper/show_create_group_panel.dart';
import '../cubit/product_wizard_cubit.dart';
import '../cubit/product_wizard_state.dart';


class Step3Complements extends StatelessWidget {
  const Step3Complements({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductWizardCubit, ProductWizardState>(
      builder: (context, state) {
        final mainContent = _buildMainContent(context, state);

        return ResponsiveBuilder(
          mobileBuilder: (context, constraints) => mainContent,
          desktopBuilder: (context, constraints) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: mainContent,
              ),
              Spacer(),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(top: 32.0, right: 32.0),
                  // O mockup agora precisa receber a lista de links do estado
                  child: ProductPhoneMockup(
                    product: state.productInCreation.copyWith(
                      variantLinks: state.variantLinks,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context, ProductWizardState state) {
    final bool hasNoLinks = state.variantLinks.isEmpty;
    return SingleChildScrollView( // Adicionado
      child: hasNoLinks
          ? _buildEmptyState(context)
          : _buildComplementsList(context, state),
    );
  }


// Dentro da classe _Step3ComplementsState

// ✅ FUNÇÃO ATUALIZADA PARA CRIAR E EDITAR
  Future<void> _openPanel(BuildContext context, {ProductVariantLink? linkToEdit}) async {
    final cubit = context.read<ProductWizardCubit>();
    final bool isEditMode = linkToEdit != null;

    // Usa o seu helper que já existe para mostrar o painel
    final resultLink = await showCreateGroupPanel(
      context,
      productId: cubit.state.productInCreation.id,
      linkToEdit: linkToEdit, // ✅ Passa o link para o helper, se estiver editando
    );

    // Se o painel retornou um resultado (o usuário salvou)...
    if (resultLink != null && context.mounted) {
      // ...chama o método correto no Cubit para atualizar o estado.
      if (isEditMode) {
        // Se estava editando, atualiza o link existente na lista
        cubit.updateVariantLink(resultLink);
      } else {
        // Se estava criando, adiciona o novo link à lista
        cubit.addVariantLink(resultLink);
      }
    }
  }


  Widget _buildEmptyState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        Image.asset('assets/images/complements.png', height: 150), // Adicione uma imagem legal
        const SizedBox(height: 24),
        Text(
          "Clientes amam personalizar!",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "Crie grupos como 'Escolha sua bebida', 'Adicionais' ou 'Ponto da carne' para aumentar o valor do seu pedido.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => _openPanel(context),
          icon: const Icon(Icons.add),
          label: const Text("Adicionar Primeiro Grupo"),
        ),
      ],
    );
  }

  Widget _buildComplementsList(BuildContext context, ProductWizardState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Grupos de Complementos", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () => _openPanel(context),
              icon: const Icon(Icons.add),
              label: const Text("Adicionar grupo"),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.variantLinks.length,
          itemBuilder: (context, index) {
            final link = state.variantLinks[index];
            return VariantLinkCard(
              key: ValueKey(link.variant.id ?? index),
              link: link,
              onRemoveLink: () => context.read<ProductWizardCubit>().removeVariantLink(link),
              onLinkRulesChanged: (updatedLink) => context.read<ProductWizardCubit>().updateVariantLink(updatedLink),

              // ✅ Callbacks das opções agora conectados aos novos métodos do cubit
              onOptionUpdated: (updatedOption) => context.read<ProductWizardCubit>().updateOptionInLink(
                updatedOption: updatedOption,
                parentLink: link,
              ),
              onOptionRemoved: (optionToRemove) => context.read<ProductWizardCubit>()..removeOptionFromLink(
                optionToRemove: optionToRemove,
                parentLink: link,
              ),
              onLinkNameChanged: (newName) {
                context.read<ProductWizardCubit>().updateVariantLinkName(link, newName);
              },
              // ✅ IMPLEMENTAÇÃO DO NOVO CALLBACK
              onToggleAvailability: () {
                // 1. Cria uma cópia do link com o valor de 'available' invertido.
                final updatedLink = link.copyWith(available: !link.available);

                // 2. Chama o método do Cubit para salvar a mudança.
                //    A UI vai se atualizar sozinha quando o evento do socket chegar.
                context.read<ProductWizardCubit>().updateVariantLink(updatedLink);
              },

              onAddOption: () async {

              final newOption = await showAddOptionToGroupPanel(context);
              if (newOption != null) {
                // ✅ CORRETO PARA O WIZARD: Adiciona a opção em memória no Cubit
                context.read<ProductWizardCubit>().addOptionToLink(newOption, link);
              }
            },
            );
          },
          onReorder: (oldIndex, newIndex) {
            context.read<ProductWizardCubit>().reorderVariantLinks(oldIndex, newIndex);
          },
        ),
      ],
    );
  }
}