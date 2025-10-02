import 'package:flutter/material.dart';
import 'package:totem_pro_admin/repositories/payment_method_repository.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';
import 'package:totem_pro_admin/core/di.dart';
import '../../core/responsive_builder.dart';
import '../../models/payment_method.dart';
import 'widgets/payment_method_group_section.dart';
import '../../widgets/app_primary_button.dart';

class PlatformPaymentMethodsPage extends StatefulWidget {
  final int storeId;
  final bool isInWizard;
  final bool isInSidePanel;

  const PlatformPaymentMethodsPage({
    super.key,
    required this.storeId,
    this.isInWizard = false,
    this.isInSidePanel = false,
  });

  @override
  State<PlatformPaymentMethodsPage> createState() => PlatformPaymentMethodsPageState();
}

class PlatformPaymentMethodsPageState extends State<PlatformPaymentMethodsPage> {
  final paymentRepository = getIt<PaymentMethodRepository>();

  bool _isLoading = true;
  String? _error;
  List<PaymentMethodGroup> _paymentGroups = [];
  List<PaymentMethodGroup> _initialPaymentGroups = [];

  @override
  void initState() {
    super.initState();
    _fetchPaymentMethods();
  }

  Future<void> _fetchPaymentMethods() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await paymentRepository.getPaymentMethodsForStore(widget.storeId);

    if (!mounted) return;
    result.fold(
          (error) => setState(() {
        _error = error;
        _isLoading = false;
      }),
          (groups) => setState(() {
        _paymentGroups = groups;
        _initialPaymentGroups = groups.map((g) => g.deepCopy()).toList();
        _isLoading = false;
      }),
    );
  }

  // ✅ ================== MÉTODO 'save' CORRIGIDO ==================
  Future<void> save() async {
    setState(() { _isLoading = true; });

    final List<Future> updateFutures = [];

    // Loop simplificado: iteramos sobre os grupos e diretamente sobre seus métodos.
    for (int i = 0; i < _paymentGroups.length; i++) {
      for (int j = 0; j < _paymentGroups[i].methods.length; j++) {
        final currentMethod = _paymentGroups[i].methods[j];
        final initialMethod = _initialPaymentGroups[i].methods[j];

        // Compara a ativação do método atual com o inicial
        if (currentMethod.activation?.isActive != initialMethod.activation?.isActive) {
          updateFutures.add(
            paymentRepository.updateActivation(
              storeId: widget.storeId,
              platformMethodId: currentMethod.id,
              activation: currentMethod.activation!,
            ),
          );
        }
      }
    }

    if (updateFutures.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nenhuma alteração para salvar.')));
      setState(() { _isLoading = false; });
      return;
    }

    final results = await Future.wait(updateFutures);
    setState(() { _isLoading = false; });

    if (results.any((res) => res.isLeft)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ocorreu um erro.'), backgroundColor: Colors.red));
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alterações salvas!'), backgroundColor: Colors.green));
      if (widget.isInSidePanel) {
        Navigator.of(context).pop();
      } else {
        _fetchPaymentMethods();
      }
    }
  }
  // ================== FIM DA CORREÇÃO ==================

  // ✅ ================== MÉTODO '_handleActivationChange' CORRIGIDO ==================
  void _handleActivationChange(PlatformPaymentMethod method, bool newValue) {
    setState(() {
      _paymentGroups = _paymentGroups.map((group) {
        return group.copyWith(
          // Mapeamos diretamente os métodos do grupo.
          methods: group.methods.map((m) {
            if (m.id == method.id) {
              final activationToUpdate = m.activation ?? StorePaymentMethodActivation.empty();
              return m.copyWith(
                activation: activationToUpdate.copyWith(isActive: newValue),
              );
            }
            return m;
          }).toList(),
        );
      }).toList();
    });
  }
  // ================== FIM DA CORREÇÃO ==================

  @override
  Widget build(BuildContext context) {
    if (widget.isInSidePanel) {
      return _buildSidePanelLayout();
    }
    return widget.isInWizard
        ? _buildWizardContent()
        : _buildStandalonePage();
  }

  Widget _buildSidePanelLayout() {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Adicionar / Remover Métodos', style: Theme.of(context).textTheme.headlineSmall),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const Divider(height: 32),
            Expanded(child: _buildWizardContent()),
            const Divider(height: 32),
            SizedBox(
              width: double.infinity,
              child: AppPrimaryButton(onPressed: _isLoading ? null : save, label: 'Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandalonePage() {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar Formas de Pagamento')),
      body: _buildWizardContent(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AppPrimaryButton(onPressed: _isLoading ? null : save, label: 'Salvar Alterações'),
      ),
    );
  }

  Widget _buildWizardContent() {
    if (_isLoading) return const Center(child: DotLoading());
    if (_error != null) return Center(child: Text('Erro: $_error'));

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveBuilder.isMobile(context) ? 8 : 24.0),
      itemCount: _paymentGroups.length,
      itemBuilder: (context, index) {
        final group = _paymentGroups[index];
        return PaymentMethodGroupSection(
          group: group,
          onActivationChanged: _handleActivationChange,
        );
      },
    );
  }
}