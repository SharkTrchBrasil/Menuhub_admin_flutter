import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';



import '../../../../widgets/mobile_mockup.dart';
import '../../../models/products/product_variant_link.dart';
import '../../../widgets/ds_primary_button.dart';
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



  Future<void> _openPanel(BuildContext context, {ProductVariantLink? linkToEdit}) async {
    final cubit = context.read<ProductWizardCubit>();
    final bool isEditMode = linkToEdit != null;

    final resultLink = await showCreateGroupPanel(
      context,
      productId: cubit.state.productInCreation.id,
      linkToEdit: linkToEdit,
    );
    if (resultLink != null && context.mounted) {
       if (isEditMode) {
         cubit.updateVariantLink(resultLink);
      } else {
        cubit.addVariantLink(resultLink);
      }
    }
  }




  Widget _buildEmptyState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        SvgPicture.asset('assets/icons/food.svg', height: 120), // Adicione uma imagem legal
        const SizedBox(height: 34),
        Text(
          "Mais Opções para o Cliente, Mais Lucro para Você!",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),


        const SizedBox(height: 44),


        // Botão alinhado à direita
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
        //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
      onPressed: () => _openPanel(context),
      label: 'Adicionar novo grupo',

    );
  }

  Widget _buildComplementsList(BuildContext context, ProductWizardState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),

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

  Widget _buildHeader(BuildContext context) {
    // Verifica se é mobile baseado na largura da tela
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
        // Título
        Expanded(
          child: Text(
            "Grupos de Complementos: os clientes amam e você vende mais",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF151515), // ifdl-text-color-primary

            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const SizedBox(width: 16),

        // Botão
        _buildAddButton(context),
      ],
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
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

        // Botão alinhado à direita
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


}