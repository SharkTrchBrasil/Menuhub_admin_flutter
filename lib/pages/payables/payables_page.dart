
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/pages/payables/widgets/financial-entry_dialog.dart';

import 'package:totem_pro_admin/pages/payables/widgets/payable_view.dart';
import 'package:totem_pro_admin/pages/payables/widgets/receivable_view.dart';
import 'package:totem_pro_admin/pages/payables/widgets/supplier_view.dart';


import '../../core/responsive_builder.dart';

import '../../cubits/store_manager_cubit.dart';
import '../../cubits/store_manager_state.dart';


import '../../models/store/store_payable.dart';
import '../../models/store/store_receivable.dart';
import '../../repositories/store_repository.dart';
import '../../services/dialog_service.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/fixed_header.dart';
import '../../widgets/mobileappbar.dart';
import '../base/BasePage.dart';
import '../../core/di.dart';

// ✅ 1. Enum para controlar o que o dialog vai criar/editar
enum FinancialEntryType { payable, receivable, supplier, payableCategory, receivableCategory }



class PayablePage extends StatefulWidget {
  const PayablePage({super.key, required this.storeId});
  final int storeId;

  @override
  State<PayablePage> createState() => _PayablePageState();
}

class _PayablePageState extends State<PayablePage> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: ResponsiveBuilder.isMobile(context) ? 14 : 24.0,),
      child: BasePage(

        mobileBuilder: (context) => _buildContent(context, isMobile: true),
        desktopBuilder: (context) => _buildContent(context, isMobile: false),

        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Widget _buildContent(BuildContext context, {required bool isMobile}) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        // ✅ ALTERAÇÃO: Pega a lista de recebíveis do estado
        final payables = state.activeStore?.relations.payables ?? [];
        final suppliers = state.activeStore?.relations.suppliers ?? [];
        final receivables = state.activeStore?.relations.receivables ?? [];

        final tabViews = [
          PayablesView(
            payables: payables,
            storeId: widget.storeId,
            onDeletePayable: _deletePayable,
            onAddPayable: () {  },
            onEditPayable: (StorePayable ) {  },
          ),
          SuppliersView(suppliers: suppliers),

          ReceivablesView(
            receivables: receivables,
            storeId: widget.storeId,
            onDeleteReceivable: _deleteReceivable,
          ),
        ];

        return Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMobile)
              FixedHeader(
                title: 'Gestão Financeira',
                subtitle: 'Gerencie as despesas, pagamentos e fornecedores da sua loja.',
                actions: _getHeaderActions(),
              ),
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Theme.of(context).primaryColor,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 16),
              tabs: const [
                Tab(text: 'Contas a Pagar'),
                Tab(text: 'Fornecedores'),
                Tab(text: 'Contas a Receber'),
              ],
            ),
            Expanded(
              child: Padding(
                padding: isMobile ? EdgeInsets.zero : const EdgeInsets.only(top: 24.0),
                child: tabViews[_tabController.index],
              ),
            ),
          ],
        );
      },
    );
  }

  // ✅ ADIÇÃO: Lógica para criar o FAB dinamicamente
  Widget? _buildFloatingActionButton() {
    switch (_tabController.index) {
      case 0: // Contas a Pagar
        return FloatingActionButton(onPressed: _addPayable, tooltip: 'Nova Conta', child: const Icon(Icons.add));
      case 1: // Fornecedores
        return FloatingActionButton(onPressed: _addSupplier, tooltip: 'Novo Fornecedor', child: const Icon(Icons.person_add));
      case 2: // Contas a Receber
        return FloatingActionButton(onPressed: _addReceivable, tooltip: 'Novo Recebível', child: const Icon(Icons.add_card));
      default:
        return null;
    }
  }

  // ✅ ALTERAÇÃO: Adiciona a ação para a aba de Contas a Receber
  List<Widget> _getHeaderActions() {
    switch (_tabController.index) {
      case 0:
        return [AppPrimaryButton(label: 'Adicionar Conta', onPressed: _addPayable)];
      case 1:
        return [AppPrimaryButton(label: 'Adicionar Fornecedor', onPressed: _addSupplier)];
      case 2:
        return [AppPrimaryButton(label: 'Adicionar Recebível', onPressed: _addReceivable)];
      default:
        return [];
    }
  }



  // ✅ 2. MÉTODOS DE AÇÃO AGORA CHAMAM A FUNÇÃO DO DIALOG
  void _addPayable() => _showFinancialEntryDialog(type: FinancialEntryType.payable);
  void _addSupplier() => _showFinancialEntryDialog(type: FinancialEntryType.supplier);
  void _addReceivable() => _showFinancialEntryDialog(type: FinancialEntryType.receivable);


  Future<void> _deletePayable(StorePayable payable) async {
    final confirmed = await DialogService.showConfirmationDialog(context, title: 'Confirmar Exclusão', content: 'Excluir a conta "${payable.title}"?');
    if (confirmed == true) {
      await getIt<StoreRepository>().deletePayable(widget.storeId, payable.id!);
    }
  }

  Future<void> _deleteReceivable(StoreReceivable receivable) async {
    final confirmed = await DialogService.showConfirmationDialog(context, title: 'Confirmar Exclusão', content: 'Excluir o recebível "${receivable.title}"?');
    if (confirmed == true) {
      // TODO: Criar o método no repositório
      // await getIt<StoreRepository>().deleteReceivable(widget.storeId, receivable.id!);
    }
  }


  // ✅ 3. MÉTODO PRINCIPAL QUE ABRE O DIALOG REUTILIZÁVEL
  Future<void> _showFinancialEntryDialog({
    required FinancialEntryType type,
    dynamic itemToEdit,
  }) async {
    // A chamada para showDialog agora mostra o widget que definimos abaixo
    await showDialog(
      context: context,
      builder: (_) => FinancialEntryDialog(
        storeId: widget.storeId,
        type: type,
        itemToEdit: itemToEdit,
      ),
    );
  }
}





