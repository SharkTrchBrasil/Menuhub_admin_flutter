import 'package:flutter/material.dart';

import '../../../core/responsive_builder.dart';
import '../../../models/category.dart';
import '../../../widgets/ds_primary_button.dart';



class CategoryCardHeader extends StatelessWidget {
  final Category category;
  final int productCount;
  final bool isEditingName;
  final TextEditingController nameController;
  final VoidCallback onEditName;
  final VoidCallback onSaveName;
  final VoidCallback onCancelEditName;
  final VoidCallback onAddItem;
  final VoidCallback onToggleStatus;
  final VoidCallback onEditCategory;
  final VoidCallback onDeleteCategory;

  const CategoryCardHeader({
    required this.category,
    required this.productCount,
    required this.isEditingName,
    required this.nameController,
    required this.onEditName,
    required this.onSaveName,
    required this.onCancelEditName,
    required this.onAddItem,
    required this.onToggleStatus,
    required this.onEditCategory,
    required this.onDeleteCategory,
  });

  @override
  Widget build(BuildContext context) {
    // Esconde os botões principais se o nome estiver sendo editado
    if (isEditingName) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: nameController,
                autofocus: true,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                onSubmitted: (_) => onSaveName(),
              ),
            ),
            IconButton(icon: const Icon(Icons.close), onPressed: onCancelEditName, color: Colors.red),
            IconButton(icon: const Icon(Icons.check), onPressed: onSaveName, color: Colors.green),
          ],
        ),
      );
    }

    // Layout padrão do cabeçalho
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Nome da Categoria
          IconButton(
            icon: Icon(Icons.edit, size: 18, color: Colors.grey.shade600),
            onPressed: onEditName,
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: category.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: ' ($productCount ${productCount == 1 ? "item" : "itens"})',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.grey.shade700),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          // Botões de Ação
          if (ResponsiveBuilder.isDesktop(context)) ...[
            OutlinedButton(onPressed: () {}, child: const Text('Criar combo')),
            const SizedBox(width: 8),
            DsButton(
              label: 'Adicionar item',
              style: DsButtonStyle.custom,
              backgroundColor: Colors.white,      // Fundo branco
              foregroundColor: Colors.black,      // Texto preto
              borderColor: Colors.transparent,
              minimumSize: const Size(160, 42),// Borda transparente (invisível)
              onPressed: onAddItem,
            ),


            const SizedBox(width: 8),
          ],
          IconButton(
            tooltip: category.active ? "Pausar vendas nesta categoria" : "Ativar vendas nesta categoria",
            icon: Icon(category.active ? Icons.pause_circle_outline : Icons.play_circle_outline),
            color: category.active ? Colors.orange.shade700 : Colors.green.shade700,
            onPressed: onToggleStatus,
          ),
          // Menu de mais opções
          PopupMenuButton<String>(
            tooltip: "Mais opções",
            onSelected: (value) {
              if (value == 'edit') onEditCategory();
              if (value == 'delete') onDeleteCategory();
              // Adicionar outras ações como "Duplicar"
            },
            itemBuilder: (context) => [
              if (ResponsiveBuilder.isMobile(context))
                const PopupMenuItem(value: 'add', child: Text('Adicionar item')),
              const PopupMenuItem(value: 'edit', child: Text('Editar categoria')),
              const PopupMenuItem(value: 'duplicate', child: Text('Duplicar categoria')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'delete', child: Text('Remover categoria', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
    );
  }
}

