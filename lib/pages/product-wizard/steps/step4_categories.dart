import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/models/category.dart';

import 'package:totem_pro_admin/widgets/app_text_field.dart';

import '../../../../cubits/store_manager_state.dart';
import '../../../../models/prodcut_category_links.dart';
import '../cubit/product_wizard_cubit.dart';
import '../cubit/product_wizard_state.dart';




class Step4Categories extends StatelessWidget {
  const Step4Categories({super.key});

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final wizardCubit = context.read<ProductWizardCubit>();

    // Pega todas as categorias disponíveis da loja através do StoresManagerCubit
    final storesState = context.read<StoresManagerCubit>().state;
    if (storesState is! StoresManagerLoaded) return;
    final allCategories = storesState.activeStore?.relations.categories ?? [];

    final selectedCategory = await showDialog<Category>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Adicionar a uma categoria"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: allCategories.length,
            itemBuilder: (listCtx, index) {
              final category = allCategories[index];
              return ListTile(
                title: Text(category.name),
                onTap: () => Navigator.of(ctx).pop(category),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancelar"),
          )
        ],
      ),
    );

    if (selectedCategory != null) {
      wizardCubit.addCategoryLink(selectedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductWizardCubit, ProductWizardState>(
      builder: (context, state) {
        return SingleChildScrollView(

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Disponível em:',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Adicione o produto em uma ou mais categorias e defina suas regras de venda.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              _buildTableHeader(),
              const Divider(height: 1),
              if (state.categoryLinks.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                      child: Text(
                          "Este produto precisa estar em pelo menos uma categoria.")),
                )
              else
                ...state.categoryLinks
                    .map((link) => _CategoryLinkRow(key: ValueKey(link.category?.id), link: link)),

              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _showAddCategoryDialog(context),
                icon: const Icon(Icons.add),
                label: const Text("Adicionar categoria"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableHeader() {
    final headerStyle = TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.bold);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text("CATEGORIA", style: headerStyle)),
          Expanded(flex: 2, child: Text("PREÇO", style: headerStyle)),
          Expanded(flex: 2, child: Text("CÓDIGO PDV (OPCIONAL)", style: headerStyle)),
          const SizedBox(width: 48), // Espaço para o botão de remover
        ],
      ),
    );
  }
}

class _CategoryLinkRow extends StatefulWidget {
  final ProductCategoryLink link;
  const _CategoryLinkRow({super.key, required this.link});

  @override
  State<_CategoryLinkRow> createState() => _CategoryLinkRowState();
}

class _CategoryLinkRowState extends State<_CategoryLinkRow> {
  late final TextEditingController _priceController;
  late final TextEditingController _pdvController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.link.price != null
          ? UtilBrasilFields.obterReal(widget.link.price! / 100)
          : '',
    );
    _pdvController = TextEditingController(text: widget.link.posCode ?? '');
  }

  @override
  void dispose() {
    _priceController.dispose();
    _pdvController.dispose();
    super.dispose();
  }

  void _updateLink() {
    final priceText = _priceController.text;
    final priceInCents = priceText.isNotEmpty
        ? (UtilBrasilFields.converterMoedaParaDouble(priceText) * 100).toInt()
        : null;

    final updatedLink = widget.link.copyWith(
      price: priceInCents,
      posCode: _pdvController.text.isNotEmpty ? _pdvController.text : null,
    );
    context.read<ProductWizardCubit>().updateCategoryLink(updatedLink);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 3, child: Text(widget.link.category?.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            flex: 2,
            child: AppTextField(

              hint: '0,00',
              formatters: [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter(moeda: true)],
              keyboardType: TextInputType.number,
              onTapOutside: (_) => _updateLink(), title: '',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: AppTextField(

              hint: 'CSAXDR',
              onTapOutside: (_) => _updateLink(), title: '',
            ),
          ),
          SizedBox(
            width: 48,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => context.read<ProductWizardCubit>().removeCategoryLink(widget.link),
            ),
          ),
        ],
      ),
    );
  }
}