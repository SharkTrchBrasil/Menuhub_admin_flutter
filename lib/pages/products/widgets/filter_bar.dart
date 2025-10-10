import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import '../../../core/responsive_builder.dart';

class FilterBar extends StatefulWidget {
  final TextEditingController searchController;
  final List<Category> categories;
  final Category? selectedValue;
  final ValueChanged<Category?> onCategoryChanged;
  final VoidCallback onAddCategory;
  final ValueChanged<List<Category>> onReorder;

  const FilterBar({
    super.key,
    required this.searchController,
    required this.categories,
    this.selectedValue,
    required this.onCategoryChanged,
    required this.onAddCategory,
    required this.onReorder,
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  void _showCategoryFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Filtrar por Categoria',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text('Todas as categorias',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () {
                      widget.onCategoryChanged(null);
                      Navigator.pop(context);
                    },
                  ),
                  ...widget.categories.map((cat) => ListTile(
                    title: Text(cat.name),
                    onTap: () {
                      widget.onCategoryChanged(cat);
                      Navigator.pop(context);
                    },
                  )),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showReorderDialog(BuildContext context, bool isMobile) {
    final dialogContent = _ReorderCategoriesDialog(
      initialCategories: widget.categories,
      onReorder: widget.onReorder,
    );

    if (isMobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => dialogContent,
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: dialogContent,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBuilder.isMobile(context);

    return Container(
      // padding: EdgeInsets.symmetric(
      //   vertical: 16.0,
      // ),
      child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: _buildSearchField(),
        ),
        SizedBox(width: 16),

        Expanded(
          flex: 2,
          child: _buildCategoryDropdown(),
        ),

        Expanded(child: const SizedBox(width: 16)),
        Expanded(
          child: DsButton(
            onPressed: widget.onAddCategory,
            label: 'Adicionar Categoria',
            style: DsButtonStyle.custom,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            borderColor: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _buildSearchField()),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _showCategoryFilterSheet(context),
              icon: const Icon(Icons.tune),
              tooltip: 'Filtrar',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 40, // Mesma altura do dropdown
      child: TextField(
        controller: widget.searchController,
        decoration: InputDecoration(
          hintText: 'Buscar um item',
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      height: 40, // Mesma altura do search field
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white, // Fundo branco igual ao search field
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Colors.grey.shade400, // Borda cinza igual ao search field
          width: 1.0,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Category?>(
          hint: const Text('Todas'),
          value: widget.selectedValue,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          style: Theme.of(context).textTheme.bodyMedium,
          items: [
            const DropdownMenuItem<Category?>(
              value: null,
              child: Text('Todas'),
            ),
            ...widget.categories.map((Category category) {
              return DropdownMenuItem<Category?>(
                value: category,
                child: Text(category.name, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
          ],
          onChanged: widget.onCategoryChanged,
          dropdownColor: Colors.white,
        ),
      ),
    );
  }
}

class _ReorderCategoriesDialog extends StatefulWidget {
  final List<Category> initialCategories;
  final ValueChanged<List<Category>> onReorder;

  const _ReorderCategoriesDialog({
    required this.initialCategories,
    required this.onReorder,
  });

  @override
  State<_ReorderCategoriesDialog> createState() => _ReorderCategoriesDialogState();
}

class _ReorderCategoriesDialogState extends State<_ReorderCategoriesDialog> {
  late List<Category> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.initialCategories);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile)
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          Text(
            'Reordenar Categorias',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          const Text('Arraste para reorganizar a ordem das categorias:'),
          const SizedBox(height: 16),
          Expanded(
            child: ReorderableListView(
              padding: EdgeInsets.zero,
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final Category item = _items.removeAt(oldIndex);
                  _items.insert(newIndex, item);
                  widget.onReorder(_items);
                });
              },
              children: _items.map((item) => ListTile(
                key: Key(item.id.toString()),
                title: Text(item.name),
                leading: const Icon(Icons.drag_handle, color: Colors.grey),
                tileColor: Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              )).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}