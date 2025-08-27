// Substitua o conteúdo do seu arquivo variant_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/variant.dart';
import 'package:totem_pro_admin/models/variant_option.dart';
import 'package:totem_pro_admin/pages/variants/widgets/complements_tab.dart';
import 'package:totem_pro_admin/pages/variants/widgets/linked_products_tab.dart';



class VariantEditScreen extends StatefulWidget {
  final Variant variant;

  const VariantEditScreen({super.key, required this.variant});

  @override
  State<VariantEditScreen> createState() => _VariantEditScreenState();
}

class _VariantEditScreenState extends State<VariantEditScreen> {
  late Variant _editableVariant;
  late TextEditingController _nameController;
  bool _hasChanges = false; // Controla se há alterações para salvar

  @override
  void initState() {
    super.initState();
    // Cria uma cópia profunda para edição segura
    _editableVariant = widget.variant.copyWith(
      options: List<VariantOption>.from(widget.variant.options.map((opt) => opt.copyWith())),
    );
    _nameController = TextEditingController(text: _editableVariant.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Callback para receber a lista de opções atualizada da aba de complementos
  void _onOptionsChanged(List<VariantOption> updatedOptions) {
    setState(() {
      _editableVariant = _editableVariant.copyWith(options: updatedOptions);
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: _buildAppBarTitle(),
          actions: [
            TextButton.icon(
              onPressed: () {
                // TODO: Implementar a lógica de pausar/ativar o grupo
                print('Pausar/Ativar grupo');
                setState(() => _hasChanges = true);
              },
              icon: const Icon(Icons.pause), // Ícone precisa ser dinâmico
              label: const Text('Pausar grupo'),
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
            ),
            const SizedBox(width: 16),
          ],
          bottom: const TabBar(
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Complementos'),
              Tab(text: 'Produtos vinculados'),
            ],
          ),
        ),
        body: TabBarView(

          children: [
            ComplementsTab(
              options: _editableVariant.options,
              onOptionsChanged: _onOptionsChanged,
              variantId: _editableVariant.id, // Passa o ID do grupo
            ),
            const LinkedProductsTab(), // Placeholder
          ],
        ),
        bottomNavigationBar: _buildBottomActionBar(),
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _nameController,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              hintText: 'Nome do Grupo',
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) {
              _editableVariant = _editableVariant.copyWith(name: value);
              if (!_hasChanges) setState(() => _hasChanges = true);
            },
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.edit, color: Colors.grey, size: 20),
      ],
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _hasChanges ? () {
              // TODO: Chamar o cubit/repositório para salvar o _editableVariant
              print('Salvando alterações...');
              Navigator.of(context).pop();
            } : null, // Desabilita o botão se não houver mudanças
            child: const Text('Salvar alterações'),
          ),
        ],
      ),
    );
  }
}