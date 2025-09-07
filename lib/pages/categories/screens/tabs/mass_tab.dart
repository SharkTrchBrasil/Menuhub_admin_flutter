import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/models/pizza_model.dart';
import 'package:totem_pro_admin/pages/categories/cubit/category_wizard_cubit.dart';
import 'package:flutter/services.dart';
import 'package:totem_pro_admin/pages/categories/screens/tabs/widgets/tab_header.dart';

import '../../../../core/enums/pizzaoption.dart'; // Para formatadores de texto

class PizzaOptionsTab extends StatelessWidget {
  final PizzaOptionType type;
  const PizzaOptionsTab({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryWizardCubit, CategoryWizardState>(
      builder: (context, state) {
        final cubit = context.read<CategoryWizardCubit>();

        // ✅ LÓGICA DINÂMICA: Decide qual lista e métodos usar
        final List<PizzaOption> options = type == PizzaOptionType.dough ? state.pizzaDoughs : state.pizzaEdges;
        final String title = type == PizzaOptionType.dough ? 'Massa' : 'Borda';
        final String subtitle = type == PizzaOptionType.dough
            ? 'Indique aqui os tipos de massa que sua loja trabalha.'
            : 'Indique aqui os tipos de borda que sua loja oferece.';
        final VoidCallback onAdd = type == PizzaOptionType.dough ? cubit.addPizzaDough : cubit.addPizzaEdge;

        return Scaffold(

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ 2. SUBSTITUA O TEXTO ANTIGO PELO NOVO WIDGET
                TabHeader(
                  title: title,
                  subtitle: subtitle,

                ),




                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 700;
                    if (isMobile) {
                      return _buildMobileList(context, options);
                    } else {
                      return _buildDesktopTable(context, options);
                    }
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: Text('Adicionar nova $title'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFEA1D2C),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // O cabeçalho da página
  Widget _buildHeader(String title, String subtitle) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3E3E3E)),
        ),
        SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
        ),
      ],
    );
  }

  // Constrói a tabela para desktop
  Widget _buildDesktopTable(BuildContext context, List<PizzaOption> massas) {

    final cubit = context.read<CategoryWizardCubit>();


    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEBEBEB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header da tabela
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(

              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                SizedBox(width: 40), // Espaço para o ícone de arrastar
                Expanded(flex: 3, child: Text('Massa', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('Preço', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Cód. PDV', style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 120, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center,)),
                SizedBox(width: 48), // Espaço para o botão de deletar
              ],
            ),
          ),
          Divider(height: 1, color: Color(0xFFEBEBEB)),
          SizedBox(height: 12,),
          // Linhas da tabela
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: massas.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16,),
            itemBuilder: (context, index) {

              // ✅ LÓGICA DINÂMICA
              final ValueChanged<PizzaOption> onUpdate = type == PizzaOptionType.dough ? cubit.updatePizzaDough : cubit.updatePizzaEdge;
              final VoidCallback onRemove = type == PizzaOptionType.dough ? () => cubit.removePizzaDough(massas[index].id) : () => cubit.removePizzaEdge(massas[index].id);


              return _MassaRowItem(
                key: ValueKey(massas[index].id),
                massa: massas[index],
                onUpdate: onUpdate,
                onRemove: onRemove,
              );
            },
          ),
        ],
      ),
    );
  }

  // Constrói a lista de cards para mobile
  Widget _buildMobileList(BuildContext context, List<PizzaOption> massas) {
    final cubit = context.read<CategoryWizardCubit>();
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: massas.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {

        // ✅ LÓGICA DINÂMICA
        final ValueChanged<PizzaOption> onUpdate = type == PizzaOptionType.dough ? cubit.updatePizzaDough : cubit.updatePizzaEdge;
        final VoidCallback onRemove = type == PizzaOptionType.dough ? () => cubit.removePizzaDough(massas[index].id) : () => cubit.removePizzaEdge(massas[index].id);


        return _MassaCardItem(
          key: ValueKey(massas[index].id),
          massa: massas[index],
          onUpdate: onUpdate,
          onRemove: onRemove,
        );
      },
    );
  }
}

// =======================================================================
// WIDGETS AUXILIARES PARA CADA ITEM DA LISTA (DESKTOP E MOBILE)
// =======================================================================

// --- WIDGET PARA A LINHA DA TABELA NO DESKTOP ---
class _MassaRowItem extends StatefulWidget {
  final PizzaOption massa;
  final ValueChanged<PizzaOption> onUpdate;
  final VoidCallback onRemove;

  const _MassaRowItem({super.key, required this.massa, required this.onUpdate, required this.onRemove});

  @override
  State<_MassaRowItem> createState() => _MassaRowItemState();
}

class _MassaRowItemState extends State<_MassaRowItem> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _pdvController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.massa.name);
    _priceController = TextEditingController(text: (widget.massa.price / 100).toStringAsFixed(2));
    _pdvController = TextEditingController(text: widget.massa.externalCode);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _pdvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [


          Expanded(
            flex: 3,
            child: TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
              onChanged: (value) => widget.onUpdate(widget.massa.copyWith(name: value)),
            ),
          ),

          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: TextFormField(
              controller: _priceController,


              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CentavosInputFormatter(moeda: true),
              ],
              decoration: InputDecoration(
                isDense: true,
                border:  OutlineInputBorder(borderRadius: BorderRadius.circular(6)),

                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

              ),






              onChanged: (value) {
                final doubleValue = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
                widget.onUpdate(widget.massa.copyWith(price: (doubleValue * 100).round()));
              },
            ),
          ),

          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _pdvController,
              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
              onChanged: (value) => widget.onUpdate(widget.massa.copyWith(externalCode: value)),
            ),
          ),

          const SizedBox(width: 16),
          SizedBox(
            width: 120,
            child: Center(
              child: Switch(
                value: widget.massa.isAvailable,
                onChanged: (value) => widget.onUpdate(widget.massa.copyWith(isAvailable: value)),
              ),
            ),
          ),

          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: widget.onRemove,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

// --- WIDGET PARA O CARD NO MOBILE ---
class _MassaCardItem extends StatefulWidget {
  final PizzaOption massa;
  final ValueChanged<PizzaOption> onUpdate;
  final VoidCallback onRemove;

  const _MassaCardItem({super.key, required this.massa, required this.onUpdate, required this.onRemove});

  @override
  State<_MassaCardItem> createState() => _MassaCardItemState();
}

class _MassaCardItemState extends State<_MassaCardItem> {
  // Gerenciamento de controllers para performance
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _pdvController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.massa.name);
    _priceController = TextEditingController(text: (widget.massa.price / 100).toStringAsFixed(2));
    _pdvController = TextEditingController(text: widget.massa.externalCode);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _pdvController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Text(widget.massa.isAvailable ? 'Ativo' : 'Pausado', style: TextStyle(color: widget.massa.isAvailable ? Colors.green : Colors.grey, fontWeight: FontWeight.bold)),
                Switch(value: widget.massa.isAvailable, onChanged: (value) => widget.onUpdate(widget.massa.copyWith(isAvailable: value))),
              ],
            ),
            const Divider(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome da Massa'),
              onChanged: (value) => widget.onUpdate(widget.massa.copyWith(name: value)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Preço', prefixText: 'R\$ '),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      final doubleValue = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
                      widget.onUpdate(widget.massa.copyWith(price: (doubleValue * 100).round()));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _pdvController,
                    decoration: const InputDecoration(labelText: 'Cód. PDV'),
                    onChanged: (value) => widget.onUpdate(widget.massa.copyWith(externalCode: value)),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: widget.onRemove,
              ),
            ),
          ],
        ),
      ),
    );
  }
}