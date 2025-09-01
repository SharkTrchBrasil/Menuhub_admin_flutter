import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/models/product_variant_link.dart';


import 'package:totem_pro_admin/repositories/product_repository.dart';
import 'package:totem_pro_admin/widgets/mobile_mockup.dart';

import '../../../product-wizard/cubit/product_wizard_cubit.dart';
import '../../../product_groups/cubit/create_complement_cubit.dart';
import '../../../product_groups/helper/show_create_group_panel.dart';
import '../../../product_groups/helper/side_panel_helper.dart';

import '../../../product_groups/widgets/multi_step_panel_container.dart';
import '../variant_link_card.dart';

class ComplementGroupsScreen extends StatefulWidget {
  final Product product;
  const ComplementGroupsScreen({super.key, required this.product});

  @override
  State<ComplementGroupsScreen> createState() => _ComplementGroupsScreenState();
}

class _ComplementGroupsScreenState extends State<ComplementGroupsScreen> {
  // ✅ Gerencia a lista de complementos localmente para atualizações instantâneas na UI
  late List<ProductVariantLink> _currentLinks;

  @override
  void initState() {
    super.initState();
    // Inicia a lista local com os complementos que já existem no produto
    _currentLinks = List.from(widget.product.variantLinks ?? []);
  }

  /// ✅ Abre o painel lateral para criar/copiar um novo grupo de complementos
  Future<void> _openAddGroupPanel() async {
    final storesState = context.read<StoresManagerCubit>().state;
    if (storesState is! StoresManagerLoaded) return;

    // Chama o painel e aguarda o resultado (o novo ProductVariantLink)
    final newLink = await showResponsiveSidePanelGroup<ProductVariantLink>(
      context,
       panel: BlocProvider(
        create: (_) => CreateComplementGroupCubit(
          storeId: storesState.activeStore!.core.id!,
          productId: widget.product.id,
          productRepository: getIt<ProductRepository>(),
          allStoreVariants: storesState.activeStore!.relations.variants ?? [],
          allStoreProducts: storesState.activeStore!.relations.products ?? [],
        ),
        child: const FractionallySizedBox(
          heightFactor: 0.9, // Painel ocupa 90% da altura
          child: MultiStepPanelContainer(),
        ),
      ),
    );

    if (newLink != null && mounted) {
      // ✅ Se um novo link foi criado, salva no banco de dados
      final result = await getIt<ProductRepository>().linkVariantToProduct(
        storeId: storesState.activeStore!.core.id!,
        productId: widget.product.id!,
        variantId: newLink.variant.id!,
        linkData: newLink,
      );

      result.fold(
            (error) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $error"), backgroundColor: Colors.red),
        ),
            (savedLink) {
          // ✅ Sucesso: Adiciona na lista local e atualiza a UI
          setState(() {
            _currentLinks.add(savedLink);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Grupo adicionado com sucesso!"), backgroundColor: Colors.green),
          );
        },
      );
    }
  }

  void _reorderLinks(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _currentLinks.removeAt(oldIndex);
      _currentLinks.insert(newIndex, item);
      // TODO: Chamar o repositório para salvar a nova ordem (prioridade) dos links
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mainContent = _buildMainContent(context);

        if (constraints.maxWidth >= 950) {
          // --- LAYOUT DESKTOP ---
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: mainContent),
              const SizedBox(width: 24),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: ProductPhoneMockup(
                      product: widget.product.copyWith(variantLinks: () => _currentLinks),
                      width: 300
                  ),
                ),
              ),
            ],
          );
        } else {
          // --- LAYOUT MOBILE ---
          return mainContent; // O SingleChildScrollView já está no EditProductPage
        }
      },
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return _currentLinks.isEmpty
        ? _buildEmptyState(context)
        : _buildPopulatedState(context);
  }

  Widget _buildPopulatedState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () {}, // A lógica de reordenar já está no ReorderableListView
            icon: const Icon(Icons.sort, size: 20),
            label: const Text("Reordenar"),
          ),
        ),
        const SizedBox(height: 16),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _currentLinks.length,
          itemBuilder: (context, index) {
            final link = _currentLinks[index];
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
              // ✅ IMPLEMENTAÇÃO DO NOVO CALLBACK
              // Em Step3Complements.dart, no seu ReorderableListView.builder
              onAddOption: () async {
                final newOption = await showAddOptionToGroupPanel(context);
                if (newOption != null && mounted) {
                  // ✅ CORRETO PARA O WIZARD: Adiciona a opção em memória no Cubit
                  context.read<ProductWizardCubit>().addOptionToLink(newOption, link);
                }
              },

            );
          },
          onReorder: _reorderLinks,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "Este produto ainda não possui grupos de complementos.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openAddGroupPanel,
              icon: const Icon(Icons.add),
              label: const Text("Criar Primeiro Grupo"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Grupos de Complementos", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ElevatedButton.icon(
          onPressed: _openAddGroupPanel,
          icon: const Icon(Icons.add),
          label: const Text("Adicionar grupo"),
        ),
      ],
    );
  }
}