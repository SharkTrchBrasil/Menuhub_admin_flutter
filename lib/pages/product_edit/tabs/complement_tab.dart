import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:totem_pro_admin/pages/product_edit/cubit/edit_product_cubit.dart';
import 'package:totem_pro_admin/pages/product_edit/widgets/variant_link_card.dart';

import '../../../core/responsive_builder.dart';
import '../../../cubits/store_manager_cubit.dart';
import '../../../cubits/store_manager_state.dart';
import '../../../models/products/product_variant_link.dart';
import '../../../models/variant_option.dart';
import '../../../widgets/ds_primary_button.dart';
import '../../product_groups/helper/side_panel_helper.dart';
import '../../product_groups/helper/show_create_group_panel.dart';
import '../../product_groups/widgets/add_option_panel.dart';
import '../widgets/edit_option_form.dart';

class ComplementGroupsTab extends StatelessWidget {
  const ComplementGroupsTab({super.key});

  // ✅ CORRIGIDO: Agora passa os dados necessários para showCreateGroupPanel
  Future<void> _addComplementGroup(BuildContext context) async {
    final cubit = context.read<EditProductCubit>();
    final storesState = context.read<StoresManagerCubit>().state;

    if (storesState is! StoresManagerLoaded) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dados da loja não carregados.")),
        );
      }
      return;
    }

    final activeStore = storesState.activeStore;
    if (activeStore == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Loja não encontrada.")),
        );
      }
      return;
    }

    // ✅ PASSA OS DADOS NECESSÁRIOS
    final resultLink = await showCreateGroupPanel(
      context,
      storeId: activeStore.core.id!,
      allStoreVariants: activeStore.relations.variants ?? [],
      allStoreProducts: activeStore.relations.products ?? [],
      productId: cubit.state.editedProduct.id,
    );

    if (resultLink != null && context.mounted) {
      cubit.addVariantLink(resultLink);
    }
  }

  // ✅ CORRIGIDO: Agora obtém os dados de forma segura
  Future<void> _addOption(BuildContext context, ProductVariantLink link) async {
    final cubit = context.read<EditProductCubit>();
    final storesState = context.read<StoresManagerCubit>().state;

    if (storesState is! StoresManagerLoaded) return;

    final allProducts = storesState.activeStore!.relations.products ?? [];
    final allVariants = storesState.activeStore!.relations.variants ?? [];
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    VariantOption? newOption;

    if (isMobile) {
      // FLUXO MOBILE: BottomSheet com formulário direto
      newOption = await showModalBottomSheet<VariantOption>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: EditOptionForm(
            onConfirm: (createdOption) => Navigator.of(context).pop(createdOption),
            onCancel: () => Navigator.of(context).pop(),
            option: null,
          ),
        ),
      );
    } else {
      // FLUXO DESKTOP: Side Panel
      newOption = await showResponsiveSidePanelGroup<VariantOption>(
        context,
        panel: AddOptionPanel(
          allProducts: allProducts,
          allVariants: allVariants,
        ),
      );
    }

    if (newOption != null && context.mounted) {
      cubit.addOptionToLink(link, newOption);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditProductCubit, EditProductState>(
      buildWhen: (prev, current) =>
      prev.editedProduct.variantLinks != current.editedProduct.variantLinks,
      builder: (context, state) {
        final cubit = context.read<EditProductCubit>();
        final links = state.editedProduct.variantLinks ?? [];

        if (links.isEmpty) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                _buildHeader(context),
                _buildEmptyState(context),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(14.0),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(context),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final link = links[index];
                    return VariantLinkCard(
                      key: ValueKey(link.variant.id ?? link.variant.hashCode),
                      link: link,
                      onRemoveLink: () => cubit.removeVariantLink(link),
                      onLinkRulesChanged: cubit.updateVariantLink,
                      onToggleAvailability: () {
                        final updatedLink = link.copyWith(available: !link.available);
                        cubit.updateVariantLink(updatedLink);
                      },
                      onLinkNameChanged: (newName) =>
                          cubit.updateVariantLinkName(link, newName),
                      onAddOption: () => _addOption(context, link),
                      onOptionUpdated: (updatedOption) =>
                          cubit.updateOptionInLink(link, updatedOption),
                      onOptionRemoved: (optionToRemove) =>
                          cubit.removeOptionFromLink(link, optionToRemove),
                    );
                  },
                  childCount: links.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: isMobile
          ? _buildMobileHeader(context)
          : _buildDesktopHeader(context),
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            "Grupos de Complementos: os clientes amam e você vende mais",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF151515),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        _buildAddButton(context),
      ],
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mais Opções para o Cliente, Mais Lucro para Você",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildAddButton(context)),
          ],
        ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return DsButton(
      style: DsButtonStyle.secondary,
      onPressed: () => _addComplementGroup(context),
      label: 'Adicionar novo grupo',
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/icons/food.svg', height: 100),
            const SizedBox(height: 16),
            const Text(
              "Este produto ainda não possui grupos de complementos.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}