import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/products/product_variant_link.dart';
import 'package:totem_pro_admin/models/variant_option.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import 'package:totem_pro_admin/pages/product_groups/helper/side_panel_helper.dart';
import 'package:totem_pro_admin/pages/product_groups/helper/show_create_group_panel.dart';
import 'package:totem_pro_admin/pages/product_groups/widgets/add_option_panel.dart';

// ✅ USA O WIZARD CUBIT
import '../cubit/product_wizard_cubit.dart';
import '../cubit/product_wizard_state.dart';
import '../../product_edit/widgets/variant_link_card.dart';
import '../../product_edit/widgets/edit_option_form.dart';

class WizardComplementsTab extends StatelessWidget {
  const WizardComplementsTab({super.key});

  Future<void> _addComplementGroup(BuildContext context) async {
    // ✅ USA O WIZARD CUBIT
    final cubit = context.read<ProductWizardCubit>();
    final storesState = context.read<StoresManagerCubit>().state;

    if (storesState is! StoresManagerLoaded) return;

    final resultLink = await showCreateGroupPanel(
      context,
      storeId: cubit.storeId,
      allStoreVariants: storesState.activeStore!.relations.variants ?? [],
      allStoreProducts: storesState.activeStore!.relations.products ?? [],
      productId: cubit.state.productInCreation.id,
    );

    if (resultLink != null && context.mounted) {
      cubit.addVariantLink(resultLink);
    }
  }

  Future<void> _addOption(BuildContext context, ProductVariantLink link) async {
    final cubit = context.read<ProductWizardCubit>();
    final storesState = context.read<StoresManagerCubit>().state;

    if (storesState is! StoresManagerLoaded) return;

    final bool isMobile = MediaQuery.of(context).size.width < 768;

    VariantOption? newOption;

    if (isMobile) {
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
      newOption = await showResponsiveSidePanelGroup<VariantOption>(
        context,
        panel: AddOptionPanel(
          allProducts: storesState.activeStore!.relations.products ?? [],
          allVariants: storesState.activeStore!.relations.variants ?? [],
        ),
      );
    }

    if (newOption != null && context.mounted) {
      // ✅ USA O MÉTODO DO WIZARD CUBIT
      cubit.addOptionToLink(newOption, link);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ USA O BLOC BUILDER DO WIZARD
    return BlocBuilder<ProductWizardCubit, ProductWizardState>(
      buildWhen: (prev, current) =>
      prev.variantLinks != current.variantLinks,
      builder: (context, state) {
        final cubit = context.read<ProductWizardCubit>();
        final links = state.variantLinks;

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
                      onOptionUpdated: (updatedOption) {
                        // ✅ AJUSTE NA CHAMADA DO MÉTODO
                        cubit.updateOptionInLink(
                          updatedOption: updatedOption,
                          parentLink: link,
                        );
                      },
                      onOptionRemoved: (optionToRemove) {
                        // ✅ AJUSTE NA CHAMADA DO MÉTODO
                        cubit.removeOptionFromLink(
                          optionToRemove: optionToRemove,
                          parentLink: link,
                        );
                      },
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