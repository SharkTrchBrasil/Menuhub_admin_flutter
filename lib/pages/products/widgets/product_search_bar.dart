import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/category.dart'; // Certifique-se que o import está correto
import 'package:totem_pro_admin/constdata/app_colors.dart'; // Certifique-se que o import está correto

class FilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final List<Category> categories;
  final String? selectedValue;
  final ValueChanged<String?> onCategoryChanged;

  const FilterBar({
    super.key,
    required this.searchController,
    required this.categories,
    required this.selectedValue,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    // O padding horizontal é adicionado pelo SliverPersistentHeaderDelegate, então podemos removê-lo daqui
    // para evitar duplicação.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: Row(
        children: [
          // Campo de Busca
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar um item',
                prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Dropdown de Categoria
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
              ),
              hint: const Text('Selecionar categoria'),
              isExpanded: true,
              value: selectedValue,
              // Itens construídos dinamicamente + opção "Todas"
              items: [
                const DropdownMenuItem<String>(value: null, child: Text('Todas as categorias')),
                ...categories.map((c) => DropdownMenuItem(value: c.id.toString(), child: Text(c.name, overflow: TextOverflow.ellipsis,))),
              ],
              onChanged: onCategoryChanged,
            ),
          ),
          const SizedBox(width: 16),
          // Botão Reordenar
          IconButton(
            icon: const Icon(Icons.sort, color: AppColors.textDark),
            tooltip: 'Reordenar',
            onPressed: () {
              // TODO: Implementar lógica de reordenação
            },
            style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.all(12)
            ),
          ),
        ],
      ),
    );
  }
}