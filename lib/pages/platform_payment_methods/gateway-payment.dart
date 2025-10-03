import 'package:flutter/material.dart';
import 'package:totem_pro_admin/repositories/payment_method_repository.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';
import 'package:totem_pro_admin/core/di.dart';
import '../../core/responsive_builder.dart';
import '../../models/payment_method.dart';
import '../../widgets/ds_primary_button.dart';
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

  Future<void> save() async {
    setState(() { _isLoading = true; });

    final List<Future> updateFutures = [];

    for (int i = 0; i < _paymentGroups.length; i++) {
      for (int j = 0; j < _paymentGroups[i].methods.length; j++) {
        final currentMethod = _paymentGroups[i].methods[j];
        final initialMethod = _initialPaymentGroups[i].methods[j];

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

  void _handleActivationChange(PlatformPaymentMethod method, bool newValue) {
    setState(() {
      _paymentGroups = _paymentGroups.map((group) {
        return group.copyWith(
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
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,

        title:  Text(
          'Configurar Formas de Pagamento',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),


      ),

      body: Column(
        children: [
          // Header fixo com título e botão fechar


          // Conteúdo com scroll
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8),
              child: Column(
                children: [
                  Expanded(
                    child: _buildWizardContent(),
                  ),
                  const SizedBox(height: 16),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: AppPrimaryButton(
                        onPressed: _isLoading ? null : save,
                        label: 'Salvar Alterações'
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandalonePage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Formas de Pagamento'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body: _buildWizardContent(),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DsButton(
              onPressed: _isLoading ? null : save,
              isLoading: _isLoading,
              label: 'Salvar Alterações'
          ),
        ),
      ),
    );
  }

  Widget _buildWizardContent() {
    if (_isLoading) {
      return const Center(child: DotLoading());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar métodos de pagamento',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: _fetchPaymentMethods,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveBuilder.isMobile(context) ? 8 : 24.0,
        vertical: 16.0,
      ),
      itemCount: _paymentGroups.length,
      itemBuilder: (context, index) {
        final group = _paymentGroups[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: PaymentMethodGroupSection(
            group: group,
            onActivationChanged: _handleActivationChange,
          ),
        );
      },
    );
  }
}