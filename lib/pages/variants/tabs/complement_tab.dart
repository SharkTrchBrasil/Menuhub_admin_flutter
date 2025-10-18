import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:totem_pro_admin/core/responsive_builder.dart';

import 'package:totem_pro_admin/pages/variants/widgets/variant_card_item.dart';


import '../../products/widgets/sliver_persistent_header_delegate.dart';
import '../../products/widgets/universal_filter_bar.dart';
import '../cubits/variants_tab_cubit.dart';
import '../widgets/filter_and_actions_bar.dart';



class VariantsTab extends StatelessWidget {
  final int storeId;

  const VariantsTab({
    super.key,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {

    return BlocListener<VariantsTabCubit, VariantsTabState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green));
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red));
        }
      },

      child: BlocBuilder<VariantsTabCubit, VariantsTabState>(
        builder: (context, state) {
          final cubit = context.read<VariantsTabCubit>();

          // Se estiver carregando pela primeira vez, mostra um spinner.
          if (state.status == VariantsTabStatus.loading && state.allVariants.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Se não houver nenhum grupo criado.
          if (state.allVariants.isEmpty && state.status != VariantsTabStatus.loading) {
            return const _EmptyState(
              title: 'Nenhum grupo de complemento criado',
              subtitle: 'Crie grupos para organizar os itens adicionais dos seus produtos.',
              icon: Icons.list_alt_outlined,
            );
          }

          final filteredVariants = state.filteredVariants;
          final isAllSelected = state.selectedVariantIds.length == filteredVariants.length && filteredVariants.isNotEmpty;

          return CustomScrollView(
            key: const PageStorageKey('variants_tab_scroll'),
            slivers: [
       if(ResponsiveBuilder.isDesktop(context))
              const SliverToBoxAdapter(
                child: _VariantsHeader(),
              ),


              SliverPersistentHeader(
                pinned: true,
                delegate: SliverPersistentHeaderDelegateWrapper(
                  minHeight: state.selectedVariantIds.isNotEmpty ? 128 : 64,
                  maxHeight: state.selectedVariantIds.isNotEmpty ? 128 : 64,
                  child: Column(
                    children: [
                      UniversalFilterBar(
                        searchController: cubit.searchController,
                        searchHint: 'Buscar grupos de complementos',
                        showMobileFilterButton: false,
                      ),

                      if (state.selectedVariantIds.isNotEmpty) ...[
                        const Divider(height: 1),
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isAllSelected,
                                onChanged: (_) => cubit.toggleSelectAll(),
                              ),
                              const Text('Selecionar todos'),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: cubit.pauseSelectedVariants,
                                icon: const Icon(Icons.pause, color: Colors.orange, size: 18),
                                label: const Text('Pausar', style: TextStyle(color: Colors.orange)),
                              ),
                              TextButton.icon(
                                onPressed: cubit.activateSelectedVariants,
                                icon: const Icon(Icons.play_arrow, color: Colors.green, size: 18),
                                label: const Text('Ativar', style: TextStyle(color: Colors.green)),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),


              if (filteredVariants.isEmpty && state.searchText.isNotEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    title: 'Nenhum complemento encontrado',
                    subtitle: 'Tente ajustar os termos da sua busca.',
                    icon: Icons.search_off,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(14),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 550,
                      mainAxisExtent: 130,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final variant = filteredVariants[index];
                        final isSelected = state.selectedVariantIds.contains(variant.id);
                        return VariantCardItem(
                          storeId: storeId,
                          variant: variant,
                          isSelected: isSelected,

                          onTap: () => cubit.toggleVariantSelection(variant.id!),
                        );
                      },
                      childCount: filteredVariants.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _VariantsHeader extends StatelessWidget {
  const _VariantsHeader();
  @override
  Widget build(BuildContext context) {
    // ... (este widget não muda)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12,),
        const Text(
          'Grupos de complementos',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Faça ajustes ou pause os grupos de complemento do seu cardápio, como: ingredientes, produtos adicionais ou descartáveis.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
        ),
      ],
    );
  }
}




class _EmptyState extends StatelessWidget {
  // ... (código existente)
  final String title;
  final String subtitle;
  final IconData icon;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(title,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center,),
          ],
        ),
      ),
    );
  }
}



class _SliverFilterDelegate extends SliverPersistentHeaderDelegate {
  // ... (código existente)
  final Widget child;
  final double height;

  const _SliverFilterDelegate({required this.child, required this.height});

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: height,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _SliverFilterDelegate oldDelegate) {
    return height != oldDelegate.height || child != oldDelegate.child;
  }
}