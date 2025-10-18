import 'package:flutter/material.dart';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/pages/variants/tabs/complement_tab_options.dart';
import 'package:totem_pro_admin/pages/variants/tabs/linked_products_tab.dart';


import '../../core/enums/variant_edit_status.dart';
import '../../models/variant_option.dart';
import '../../widgets/ds_primary_button.dart';
import 'cubits/variant_edit_cubit.dart'; // Importe seu Cubit



import 'package:totem_pro_admin/core/responsive_builder.dart';


class VariantEditScreen extends StatelessWidget {
  const VariantEditScreen({super.key, required this.storeId});

  final int storeId;

  @override
  Widget build(BuildContext context) {

    return BlocConsumer<VariantEditCubit, VariantEditState>(
      listener: (context, state) {
        if (state.status == VariantEditStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Grupo salvo com sucesso!"), backgroundColor: Colors.green),
          );
          // O pop() já retorna para a tela anterior, o que é o comportamento esperado.
          Navigator.of(context).pop();
        } else if (state.status == VariantEditStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? "Ocorreu um erro."), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        // ResponsiveBuilder escolhe o layout correto para o tamanho da tela
        return ResponsiveBuilder(
          mobileBuilder: (ctx, constraints) => _buildMobileLayout(ctx),
          desktopBuilder: (ctx, constraints) => _buildDesktopLayout(ctx),
        );
      },
    );
  }

  // Layout profissional para Mobile, com AppBar e TabBar nativas
  Widget _buildMobileLayout(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => context.goNamed(
              'products',
              pathParameters: {'storeId': storeId.toString()},
            ),
          ),
          title: BlocSelector<VariantEditCubit, VariantEditState, String>(
            selector: (state) => state.editableVariant.name,
            builder: (context, name) => Text(
              name.isEmpty ? "Novo Grupo" : name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Complementos'),
              Tab(text: 'Produtos vinculados'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ComplementsTabEdit(), // A aba de complementos que já tínhamos
            LinkedProductsTab(),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  // Layout para Desktop, com a estrutura de header customizado
  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _VariantEditViewDesktop(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // Barra de ações compartilhada para ambos os layouts
  Widget _buildBottomBar() {
    return BlocBuilder<VariantEditCubit, VariantEditState>(
      builder: (context, state) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: DsButton(
                  onPressed: () => context.goNamed(
                    'products',
                    pathParameters: {'storeId': storeId.toString()},
                  ),


                  style: DsButtonStyle.secondary,
                  label: 'Cancelar',

                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: DsButton(
                  onPressed: (state.status == VariantEditStatus.loading || !state.hasChanges)
                      ? null
                      : () => context.read<VariantEditCubit>().saveChanges(),
                  isLoading:state.status == VariantEditStatus.loading ,
                  label: 'Salvar Alterações',

                  // ... estilos
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Widget para a UI do Desktop, para manter o código organizado
class _VariantEditViewDesktop extends StatefulWidget {
  @override
  __VariantEditViewDesktopState createState() => __VariantEditViewDesktopState();
}

class __VariantEditViewDesktopState extends State<_VariantEditViewDesktop> {
  int _selectedTab = 0;
  final List<String> _tabTitles = ['Complementos', 'Produtos vinculados'];
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final initialName = context.read<VariantEditCubit>().state.editableVariant.name;
    _nameController = TextEditingController(text: initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header com o nome editável
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: TextFormField(
            controller: _nameController,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: const InputDecoration.collapsed(hintText: 'Nome do Grupo de Complementos'),
            onChanged: context.read<VariantEditCubit>().nameChanged,
          ),
        ),
        // Barra de abas customizada
        Container(
          color: Colors.white,
          child: Row(
            // ✅ CÓDIGO FINALIZADO AQUI
            children: List.generate(_tabTitles.length, (index) {
              return TabButton(
                title: _tabTitles[index],
                // Compara o índice atual com a aba selecionada
                isSelected: _selectedTab == index,
                // Ao clicar, atualiza o estado com o novo índice
                onTap: () => setState(() => _selectedTab = index),
              );
            }),
          ),
        ),
        // Conteúdo da aba
        Expanded(
          child: Container(
            color: Colors.white,
            child: IndexedStack(
              index: _selectedTab,
              children: const [
                ComplementsTabEdit(),
                LinkedProductsTab(),
              ],
            ),
          ),
        ),
      ],
    );
  }


}




class TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const TabButton({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: isSelected
              ? const Border(
            bottom: BorderSide(color: Color(0xFFEB0033), width: 2),
          )
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFFEB0033) : const Color(0xFF666666),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}



