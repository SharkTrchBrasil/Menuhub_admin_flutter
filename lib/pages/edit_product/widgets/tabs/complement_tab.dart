import 'package:flutter/material.dart';

import '../../../../core/di.dart';
import '../../../../core/helpers/sidepanel.dart';
import '../../../../models/product.dart';
import '../../../../models/product_variant_link.dart';
import '../../../../models/variant_option.dart';
import '../../../../widgets/mobile_mockup.dart';
import '../../helper/sidepanel.dart';
import '../groups/create_group_panel.dart';
import '../groups/multi_step_panel.dart';
import '../variant_link_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Adicione os imports para seus modelos e cubits reais aqui
import '../../../../cubits/store_manager_cubit.dart';
import '../../../../cubits/store_manager_state.dart';
import '../../../../models/product.dart';
import '../../../../models/product_variant_link.dart';
import '../../../../repositories/product_repository.dart'; // Necessário para o Cubit
import '../../cubit/create_complement_cbit.dart';
import '../../cubit/create_complement_state.dart';
import '../../helper/sidepanel.dart';
import '../groups/multi_step_panel.dart';
import '../variant_link_card.dart';

class ComplementGroupsScreen extends StatelessWidget {
  final Product product;
  const ComplementGroupsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // ✅ PASSO 1: O BlocProvider agora é criado aqui, no topo da tela.
    // Isso garante que o Cubit exista durante todo o ciclo de vida da aba.
    return BlocProvider(
      create: (context) {
        // Pega as dependências do contexto (assumindo que já estão providas em um nível superior)
        final storesState = context.read<StoresManagerCubit>().state as StoresManagerLoaded;
        return CreateComplementGroupCubit(
          storeId: storesState.activeStore!.id!,
          productId: product.id!,
          productRepository: getIt<ProductRepository>(),
          allExistingVariants: storesState.activeStore!.variants ?? [],
          allExistingProducts: storesState.activeStore!.products ?? [],
        );
      },
      // ✅ PASSO 2: O BlocListener "ouve" o estado do Cubit para tomar ações.
      child: BlocListener<CreateComplementGroupCubit, CreateComplementGroupState>(
        listener: (context, state) {
          if (state.status == FormStatus.success) {
            // Se o salvamento deu certo:
            // 1. Fecha o painel lateral que está aberto
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
            // 2. Manda a tela principal recarregar os dados para mostrar o novo grupo
          //  context.read<StoresManagerCubit>().reloadActiveStore();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Grupo salvo com sucesso!"), backgroundColor: Colors.green),
            );
          }
          if (state.status == FormStatus.error) {
            // Se deu erro, mostra a mensagem
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Erro ao salvar: ${state.errorMessage}"), backgroundColor: Colors.red),
            );
          }
        },
        // O child é a sua UI normal, que não precisa de alterações.
        child: LayoutBuilder(
          builder: (context, constraints) {
            const double desktopBreakpoint = 950.0;
            final bool isDesktop = constraints.maxWidth >= desktopBreakpoint;
            final mainContent = _buildMainContent(context);

            if (isDesktop) {
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
                      child: ProductPhoneMockup(product: product, width: 300),
                    ),
                  ),
                ],
              );
            } else {
              // --- LAYOUT MOBILE ---
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  mainContent,
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildPreviewHeader(),
                  Center(child: ProductPhoneMockup(product: product, showVariants: true)),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  /// ✅ CORRIGIDO: O SingleChildScrollView extra foi removido daqui.
  Widget _buildMainContent(BuildContext context) {
    final bool hasNoLinks = product.variantLinks == null || product.variantLinks!.isEmpty;

    if (hasNoLinks) {
      return _buildEmptyState(context);
    } else {
      // Retorna apenas a Column, pois a rolagem já é fornecida pela tela pai.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildToolbar(context),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: product.variantLinks!.length,
            itemBuilder: (context, index) {
              final link = product.variantLinks![index];
              return VariantLinkCard(link: link);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          ),
        ],
      );
    }
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
              // ✅ A chamada agora é mais simples
              onPressed: () {
                showResponsiveSidePanelComplement(context, panel: const MultiStepPanelContainer(),productId: product.id!);
              },
              icon: const Icon(Icons.add),
              label: const Text("Criar Primeiro Grupo"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
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
          // ✅ A chamada agora é mais simples
          onPressed: () {
            showResponsiveSidePanelComplement(context, panel: const MultiStepPanelContainer(), productId: product.id!);
          },
          icon: const Icon(Icons.add),
          label: const Text("Adicionar grupo"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }


  Widget _buildPreviewHeader() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(Icons.phone_iphone, color: Colors.grey),
          SizedBox(width: 8),
          Text(
            "Preview no App",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }


  Widget _buildToolbar(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.sort, size: 20),
        label: const Text("Reordenar"),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey[700],
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}








