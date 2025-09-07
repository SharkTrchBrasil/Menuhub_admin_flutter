// lib/features/categories/screens/customizable_category_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:totem_pro_admin/pages/categories/screens/general_category_details_screen.dart';
import 'package:totem_pro_admin/pages/categories/screens/tabs/availability_tab.dart';
import 'package:totem_pro_admin/pages/categories/screens/tabs/mass_tab.dart';
import 'package:totem_pro_admin/pages/categories/screens/tabs/pizza_options_tab.dart' hide PizzaOptionsTab;
import 'package:totem_pro_admin/pages/categories/screens/tabs/pizza_size_tab.dart';
import 'package:totem_pro_admin/pages/categories/screens/tabs/tab_details_screen.dart';

import '../../../core/enums/form_status.dart';
import '../../../core/enums/pizzaoption.dart';
import '../../../widgets/ds_primary_button.dart';
import '../cubit/category_wizard_cubit.dart';



class CustomizableCategoryDetailsScreen extends StatefulWidget {
  const CustomizableCategoryDetailsScreen({super.key});

  @override
  State<CustomizableCategoryDetailsScreen> createState() => _CustomizableCategoryDetailsScreenState();
}

class _CustomizableCategoryDetailsScreenState extends State<CustomizableCategoryDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final int _tabCount = 5; // Total de abas

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
    // Adiciona um listener para redesenhar a tela (e o botão) quando a aba mudar
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryWizardCubit, CategoryWizardState>(
      builder: (context, state) {
        final cubit = context.read<CategoryWizardCubit>();
        final bool isDetailsValid = state.categoryName
            .trim()
            .isNotEmpty;
        final bool isLoading = state.status == FormStatus.loading;

        // Determina se estamos na última aba
        final bool isLastTab = _tabController.index == _tabCount - 1;

        // ✅ A TELA AGORA TEM SEU PRÓPRIO SCAFFOLD COM RODAPÉ DINÂMICO
        return Scaffold(
            appBar: TabBar(
              tabAlignment: TabAlignment.start,
              controller: _tabController,
              // Conecta o controller
              isScrollable: true,
              labelColor: Colors.red,
              indicatorColor: Colors.red,
              tabs: [
                const Tab(text: "Detalhes"),
                Tab(child: Text("Tamanhos", style: TextStyle(
                    color: isDetailsValid ? null : Colors.grey.shade400))),
                Tab(child: Text("Massas", style: TextStyle(
                    color: isDetailsValid ? null : Colors.grey.shade400))),
                Tab(child: Text("Bordas", style: TextStyle(
                    color: isDetailsValid ? null : Colors.grey.shade400))),
                Tab(child: Text("Disponibilidade",)),
              ],
              // Impede o clique em abas desabilitadas
              onTap: (index) {
                if (!isDetailsValid && index > 0) {
                  _tabController.index = 0;
                }
              },
            ),
            body: TabBarView(
              controller: _tabController, // Conecta o controller
              physics: isDetailsValid
                  ? const AlwaysScrollableScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              children: [
                const TabDetailsScreen(), // A aba de detalhes que criamos
                isDetailsValid
                    ? const PizzaSizesScreen()
                    : _buildDisabledTabPlaceholder(),
                // ✅ ABA DE MASSAS
                isDetailsValid
                    ?  PizzaOptionsTab(type: PizzaOptionType.dough)
                    : _buildDisabledTabPlaceholder(),

                // ✅ ABA DE BORDAS - USA O MESMO WIDGET!
                isDetailsValid
                    ?  PizzaOptionsTab(type: PizzaOptionType.edge)
                    : _buildDisabledTabPlaceholder(),
                isDetailsValid ? const AvailabilityTab() : _buildDisabledTabPlaceholder(), // ✅ NOVA TELA
              ],
            ),
            // ✅ RODAPÉ DINÂMICO
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: DsButton(
                      label: 'Cancelar',
                      style: DsButtonStyle.secondary,
                      onPressed: isLoading ? null : cubit.cancelWizard,
                    ),
                  ),
                  const SizedBox(width: 16),

                  Flexible(
                    child:
                    DsButton(
                    isLoading: isLoading,
                    // ✨ O LABEL E A AÇÃO MUDAM DE ACORDO COM A ABA
                    label: isLastTab ? "Salvar Categoria" : "Continuar",
                    onPressed: isDetailsValid && !isLoading
                        ? () {
                      if (isLastTab) {
                        cubit.submitCategory();
                      } else {
                        // Avança para a próxima aba
                        _tabController.animateTo(_tabController.index + 1);
                      }
                    }
                        : null,
                  ),
        )
                ],
              ),
            )
        );
      },
    );
  }




// Widget auxiliar para a tela de aviso
  Widget _buildDisabledTabPlaceholder() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          "Preencha o nome da categoria na aba 'Detalhes' para continuar.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}