// Em: lib/pages/categories/screens/customizable_category_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/models/option_group.dart';
import 'package:totem_pro_admin/pages/categories/screens/tabs/option_groups_tab.dart';
import 'package:totem_pro_admin/pages/categories/screens/tabs/settings_tab.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import '../cubit/category_wizard_cubit.dart';
import 'tabs/availability_tab.dart';

import 'tabs/tab_details_screen.dart';

class CustomizableCategoryDetailsScreen extends StatefulWidget {
  const CustomizableCategoryDetailsScreen({super.key});

  @override
  State<CustomizableCategoryDetailsScreen> createState() => _CustomizableCategoryDetailsScreenState();
}

// ✅ Precisamos de um TickerProvider para a animação das abas
class _CustomizableCategoryDetailsScreenState extends State<CustomizableCategoryDetailsScreen> with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Lógica para recriar o TabController quando o número de abas muda
    final groupCount = context.watch<CategoryWizardCubit>().state.optionGroups.length;
    final tabCount = 3 + groupCount; // Detalhes + N Grupos + Disponibilidade + Aba '+'

    if (_tabController?.length != tabCount) {
      // Guarda o índice atual para tentar restaurá-lo
      final oldIndex = _tabController?.index ?? 0;
      _tabController?.dispose(); // Descarta o controller antigo

      // Cria um novo controller com o tamanho correto
      _tabController = TabController(
        length: tabCount,
        vsync: this,
        initialIndex: oldIndex < tabCount ? oldIndex : tabCount - 1,
      );
      _tabController!.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryWizardCubit, CategoryWizardState>(
      builder: (context, state) {
        final cubit = context.read<CategoryWizardCubit>();
        final bool isDetailsValid = state.categoryName.trim().isNotEmpty;
        final bool isLoading = state.status == FormStatus.loading;
        final bool isEditMode = state.editingCategoryId != null;

        // ✅ Monta a lista de widgets para as abas
        final List<Widget> tabs = [
          const Tab(text: "Detalhes"),
          ...state.optionGroups.map((group) => Tab(text: group.name.isEmpty ? "Novo Grupo" : group.name)),
          const Tab(text: "Disponibilidade"),
          const Tab(text: "Configurações"),

        ];

        // ✅ Monta a lista de widgets para o CONTEÚDO das abas (AQUI ESTÁ A CORREÇÃO)
        final List<Widget> tabViews = [
          const TabDetailsScreen(),



          ...state.optionGroups.map((group) {
            return OptionGroupContentTab(
              key: ValueKey(group.localId), // Chave para o Flutter saber qual aba é qual
              group: group,
            );
          }),









          const AvailabilityTab(),


          const SettingsTab(),


        ];

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false, // Remove a seta de voltar padrão da AppBar
            elevation: 1,
            backgroundColor: Colors.white,
            flexibleSpace: Column(
              children: [
                // Aqui você pode adicionar um header se quiser, acima das abas
                const Spacer(),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: tabs,
                  onTap: (index) {
                    // Impede o clique em abas desabilitadas
                    if (!isDetailsValid && index > 0) {
                      _tabController!.index = 0;
                      return;
                    }
                    // // Se clicar na aba '+', adiciona um grupo
                    // if (isDetailsValid && index == tabs.length - 1) {
                    //   cubit.addOptionGroup();
                    //   // Anima para a penúltima aba (a que acabou de ser criada)
                    //   WidgetsBinding.instance.addPostFrameCallback((_) {
                    //     _tabController?.animateTo(tabs.length - 2);
                    //   });
                    // }
                  },
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            physics: isDetailsValid ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
            children: tabViews,
          ),
          bottomNavigationBar: _buildBottomBar(context, cubit, isEditMode, isDetailsValid, isLoading),
        );
      },
    );
  }

  // Rodapé com botão de salvar sempre ativo no modo de edição
  Widget _buildBottomBar(
      BuildContext context,
      CategoryWizardCubit cubit,
      bool isEditMode,
      bool isDetailsValid,
      bool isLoading,
      ) {
    return Container(
      padding: const EdgeInsets.all(16.0),

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
            child: DsButton(
              isLoading: isLoading,
              label: "Salvar Categoria",
              onPressed: isDetailsValid && !isLoading ? cubit.submitCategory : null,
            ),
          ),
        ],
      ),
    );
  }
}