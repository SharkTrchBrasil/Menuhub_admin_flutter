import 'package:flutter/material.dart';

import 'package:totem_pro_admin/repositories/payment_method_repository.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';
import 'package:totem_pro_admin/core/di.dart';
import '../../core/responsive_builder.dart';
import '../../models/payment_method.dart';
import 'widgets/payment_method_group_section.dart'; // Importando o widget refatorado
import '../../widgets/app_primary_button.dart';

// ✅ 1. ADICIONADO O PARÂMETRO 'isInWizard'
class PlatformPaymentMethodsPage extends StatefulWidget {
  final int storeId;
  final bool isInWizard;

  const PlatformPaymentMethodsPage({
    super.key,
    required this.storeId,
    this.isInWizard = false,
  });

  @override
  // ✅ 2. STATE COM NOME PÚBLICO
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

    final result = await paymentRepository.getPaymentMethodsForStore(
      widget.storeId,
    );

    if (!mounted) return;
    result.fold(
          (error) => setState(() {
        _error = error;
        _isLoading = false;
      }),
          (groups) => setState(() {
        _paymentGroups = groups;
        // ✅ O .map de uma Lista é mais simples e o .deepCopy() funciona
        _initialPaymentGroups = groups.map((g) => g.deepCopy()).toList();
        _isLoading = false;
      }),
    );
  }


  // ✅ 3. MÉTODO 'save' PÚBLICO PARA O WIZARD
  Future<bool> save() async {
    setState(() { _isLoading = true; });

    final List<Future> updateFutures = [];

    // Lógica para encontrar as diferenças e preparar as chamadas de API
    for (int i = 0; i < _paymentGroups.length; i++) {
      for (int j = 0; j < _paymentGroups[i].categories.length; j++) {
        for (int k = 0; k < _paymentGroups[i].categories[j].methods.length; k++) {
          final currentActivation = _paymentGroups[i].categories[j].methods[k].activation;
          final initialActivation = _initialPaymentGroups[i].categories[j].methods[k].activation;

          // Compara o estado inicial com o final
          if (currentActivation?.isActive != initialActivation?.isActive) {
            updateFutures.add(
              paymentRepository.updateActivation(
                storeId: widget.storeId,
                platformMethodId: _paymentGroups[i].categories[j].methods[k].id,
                activation: currentActivation!,
              ),
            );
          }
        }
      }
    }

    if (updateFutures.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nenhuma alteração para salvar.')));
      setState(() { _isLoading = false; });
      return true; // Nenhuma alteração significa "sucesso" para o wizard
    }

    final results = await Future.wait(updateFutures);
    setState(() { _isLoading = false; });

    if (results.any((res) => res.isLeft)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ocorreu um erro.'), backgroundColor: Colors.red));
      return false; // Falha
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alterações salvas!'), backgroundColor: Colors.green));
      _fetchPaymentMethods();
      return true; // Sucesso
    }
  }

  // Função para lidar com a mudança do Checkbox, agora trabalhando com listas
  void _handleActivationChange(PlatformPaymentMethod method, bool newValue) {
    setState(() {
      _paymentGroups =
          _paymentGroups.map((group) {
            return group.copyWith(
              categories:
              group.categories.map((category) {
                return category.copyWith(
                  methods:
                  category.methods.map((m) {
                    if (m.id == method.id) {
                      final activationToUpdate =
                          m.activation ??
                              StorePaymentMethodActivation(
                                id: 0,
                                isActive: newValue,
                                feePercentage: 0,
                                isForDelivery: true,
                                isForPickup: true,
                                isForInStore: true,
                              );
                      return m.copyWith(
                        activation: activationToUpdate.copyWith(
                          isActive: newValue,
                        ),
                      );
                    }
                    return m;
                  }).toList(),
                );
              }).toList(),
            );
          }).toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    // ✅ 4. BUILD CONDICIONAL
    return widget.isInWizard
        ? _buildWizardContent()
        : _buildStandalonePage();
  }

  // MÉTODO PARA A PÁGINA COMPLETA (MODO NORMAL)
  Widget _buildStandalonePage() {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar Formas de Pagamento')),
      body: _buildWizardContent(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AppPrimaryButton(
          onPressed: _isLoading ? null : save, // Chama o método público 'save'
          label: 'Salvar Alterações',
        ),
      ),
    );
  }

  // MÉTODO PARA O CONTEÚDO DO FORMULÁRIO (REUTILIZADO)
  Widget _buildWizardContent() {
    if (_isLoading) return const Center(child: DotLoading());
    if (_error != null) return Center(child: Text('Erro: $_error'));

    return ListView.builder(
      padding:  EdgeInsets.symmetric(horizontal: ResponsiveBuilder.isMobile(context) ? 8 : 24.0),
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

