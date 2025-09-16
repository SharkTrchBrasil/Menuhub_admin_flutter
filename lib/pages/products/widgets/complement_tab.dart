import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/models/product.dart'; // Importe o modelo Product para o ProductVariantLink
import 'package:totem_pro_admin/models/variant.dart';


class VariantsTab extends StatefulWidget {
  final List<Variant> variants;
  final int storeId;

  const VariantsTab({
    super.key,
    required this.variants, required this.storeId,
  });

  @override
  State<VariantsTab> createState() => _VariantsTabState();
}

class _VariantsTabState extends State<VariantsTab> {
  final _searchController = TextEditingController();
  String _searchText = '';
  final Set<int> _selectedVariantIds = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) {
        setState(() => _searchText = _searchController.text.toLowerCase());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleVariantSelection(int variantId) {
    setState(() {
      if (_selectedVariantIds.contains(variantId)) {
        _selectedVariantIds.remove(variantId);
      } else {
        _selectedVariantIds.add(variantId);
      }
    });
  }

  void _toggleSelectAll(List<Variant> visibleVariants) {
    setState(() {
      final allVisibleIds = visibleVariants.map((v) => v.id).whereType<int>().toSet();
      if (_selectedVariantIds.containsAll(allVisibleIds) && _selectedVariantIds.isNotEmpty) {
        _selectedVariantIds.clear();
      } else {
        _selectedVariantIds.addAll(allVisibleIds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredVariants = widget.variants
        .where((v) => v.name.toLowerCase().contains(_searchText))
        .toList();

    final isAllSelected = _selectedVariantIds.length == filteredVariants.length && filteredVariants.isNotEmpty;

    if (widget.variants.isEmpty) {
      return const _EmptyState(
        title: 'Nenhum grupo de complemento criado',
        subtitle: 'Crie grupos para organizar os itens adicionais dos seus produtos.',
        icon: Icons.list_alt_outlined,
      );
    }

    // ✅ Defina a altura desejada para a barra de filtros aqui
    const double filterBarHeight = 140.0;

    return CustomScrollView(
      key: const PageStorageKey('variants_tab_scroll'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: _VariantsHeader(),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverFilterDelegate( // ✅ Usando o delegate local e passando a altura
            height: filterBarHeight,
            child: _FilterAndActionsBar(
              searchController: _searchController,
              selectedIds: _selectedVariantIds,
              isAllSelected: isAllSelected,
              onToggleSelectAll: () => _toggleSelectAll(filteredVariants),
            ),
          ),
        ),
        if (filteredVariants.isEmpty && _searchText.isNotEmpty)
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
            padding: const EdgeInsets.all(24),
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
                  final isSelected = _selectedVariantIds.contains(variant.id);
                  return _VariantCardItem(
                    storeId: widget.storeId,
                    variant: variant,
                    isSelected: isSelected,
                    onTap: () {
                      // ✅ CORREÇÃO DO ERRO DE CLIQUE (NULL CHECK)
                      if (variant.id != null) {
                        _toggleVariantSelection(variant.id!);
                      }
                    },
                  );
                },
                childCount: filteredVariants.length,
              ),
            ),
          ),
      ],
    );
  }
}


class _VariantsHeader extends StatelessWidget {
  const _VariantsHeader();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

class _FilterAndActionsBar extends StatelessWidget {
  final TextEditingController searchController;
  final Set<int> selectedIds;
  final bool isAllSelected;
  final VoidCallback onToggleSelectAll;

  const _FilterAndActionsBar({
    required this.searchController,
    required this.selectedIds,
    required this.isAllSelected,
    required this.onToggleSelectAll,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedIds.isNotEmpty;

    return Container(

      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar grupos de complementos',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 24),
          if (hasSelection)
            ..._buildActionButtons(context)
          else
            Row(
              children: [
                Checkbox(value: false, onChanged: (_) => onToggleSelectAll),
                const Text('Selecionar todos'),
              ],
            ),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    return [
      TextButton.icon(
        onPressed: () {}, // TODO: Lógica para pausar
        icon: const Icon(Icons.pause, color: Colors.orange),
        label: const Text('Pausar', style: TextStyle(color: Colors.orange)),
      ),
      TextButton.icon(
        onPressed: () {}, // TODO: Lógica para ativar
        icon: const Icon(Icons.play_arrow, color: Colors.green),
        label: const Text('Ativar', style: TextStyle(color: Colors.green)),
      ),
      TextButton.icon(
        onPressed: () {}, // TODO: Lógica para remover
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        label: const Text('Remover', style: TextStyle(color: Colors.red)),
      ),
    ];
  }
}

class _VariantCardItem extends StatelessWidget {
  final Variant variant;
  final bool isSelected;
  final VoidCallback onTap;
  final int storeId;

  const _VariantCardItem({
    required this.variant,
    required this.isSelected,
    required this.onTap,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {


    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1),
      ),
      color: isSelected ? Colors.blue.shade50 : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => onTap(),
                    activeColor: Colors.blue,
                  ),
                  const Icon(Icons.list_alt_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      variant.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                      onPressed: () {



                        context.go(
                          '/stores/${storeId}/products/variants/${variant.id}',
                          extra: variant,
                        );

                      }, icon: const Icon(Icons.edit_outlined)),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}


class _EmptyState extends StatelessWidget {
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
        padding: const EdgeInsets.all(24.0),
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
// ✅ DELEGATE LOCAL, PRIVADO E FLEXÍVEL
class _SliverFilterDelegate extends SliverPersistentHeaderDelegate {
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








