import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/pages/edit_settings/citys/delivery_locations_page.dart';
import 'package:totem_pro_admin/pages/edit_settings/hours/hours_store_page.dart';
import 'package:totem_pro_admin/pages/edit_settings/general/store_profile_page.dart';
import 'package:totem_pro_admin/pages/edit_settings/payment_methods/payment_methods_page.dart';
import 'package:totem_pro_admin/pages/create_store/widgets/progress_bar.dart';
import 'package:totem_pro_admin/pages/create_store/widgets/wizard_layout.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';

import '../../widgets/app_toasts.dart' as AppToasts;

// 1. Enum para os novos passos de configuração
enum StoreConfigStep {
  paymentMethods,
  deliveryArea,
  openingHours,
  profile,
  menu,
}

class StoreSetupWizardPage extends StatefulWidget {
  final int storeId;
  const StoreSetupWizardPage({super.key, required this.storeId});

  @override
  State<StoreSetupWizardPage> createState() => _StoreSetupWizardPageState();
}

class _StoreSetupWizardPageState extends State<StoreSetupWizardPage> {
  StoreConfigStep _currentStep = StoreConfigStep.paymentMethods;
  bool _isLoading = false;

  // Chaves para chamar métodos `save` nas páginas filhas
  final _profileKey = GlobalKey<StoreProfilePageState>();
  final _hoursKey = GlobalKey<OpeningHoursPageState>();

  // Dicionários com os textos para cada passo, mantendo o layout
  final Map<StoreConfigStep, String> _largeTitles = {
    StoreConfigStep.paymentMethods: 'Quais formas de pagamento você aceita?',
    StoreConfigStep.deliveryArea: 'Onde você faz entregas?',
    StoreConfigStep.openingHours: 'Qual seu horário de funcionamento?',
    StoreConfigStep.profile: 'Complete o perfil da sua loja',
    StoreConfigStep.menu: 'Tudo pronto para começar!',
  };

  final Map<StoreConfigStep, String> _descriptions = {
    StoreConfigStep.paymentMethods: 'Selecione os meios de pagamento que estarão disponíveis para seus clientes.',
    StoreConfigStep.deliveryArea: 'Configure as cidades e bairros que você atende ou defina um raio de entrega.',
    StoreConfigStep.openingHours: 'Informe os dias e horários em que sua loja estará aberta para receber pedidos.',
    StoreConfigStep.profile: 'Adicione informações importantes como CNPJ, logo e banner para personalizar sua página.',
    StoreConfigStep.menu: 'Sua loja está configurada. Agora você pode ir para o painel principal e começar a cadastrar seus produtos no cardápio.',
  };

  final Map<StoreConfigStep, String> _sections = {
    StoreConfigStep.paymentMethods: 'CONFIGURAÇÃO DA LOJA',
    StoreConfigStep.deliveryArea: 'CONFIGURAÇÃO DA LOJA',
    StoreConfigStep.openingHours: 'CONFIGURAÇÃO DA LOJA',
    StoreConfigStep.profile: 'CONFIGURAÇÃO DA LOJA',
    StoreConfigStep.menu: 'CONFIGURAÇÃO DA LOJA',
  };

  Future<void> _goToNextStep() async {
    setState(() => _isLoading = true);
    bool canAdvance = false;

    // Lógica de salvamento por passo
    switch (_currentStep) {
      case StoreConfigStep.profile:
        canAdvance = await _profileKey.currentState?.save() ?? false;
        break;
      case StoreConfigStep.openingHours:
        canAdvance = await _hoursKey.currentState?.save(showSuccessToast: false) ?? false;
        break;
      case StoreConfigStep.paymentMethods:
      case StoreConfigStep.deliveryArea:
      // Essas páginas salvam automaticamente, então podemos avançar
        canAdvance = true;
        break;
      case StoreConfigStep.menu:
        await _finishSetup();
        return; // A finalização já faz a navegação
    }

    setState(() => _isLoading = false);

    if (canAdvance && _currentStep != StoreConfigStep.menu) {
      setState(() {
        _currentStep = StoreConfigStep.values[_currentStep.index + 1];
      });
    }
  }

  void _goToPreviousStep() {
    if (_currentStep.index > 0) {
      setState(() {
        _currentStep = StoreConfigStep.values[_currentStep.index - 1];
      });
    }
  }

  Future<void> _finishSetup() async {
    setState(() => _isLoading = true);
    final result = await getIt<StoreRepository>().completeStoreSetup(widget.storeId);
    setState(() => _isLoading = false);

    result.fold(
          (failure) => AppToasts.showError(failure.message),
          (_) {
        AppToasts.showSuccess('Configuração concluída! Bem-vindo(a)!');
        context.go('/stores/${widget.storeId}/dashboard');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Configure sua Loja'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: SegmentedProgressBar(
              totalSteps: StoreConfigStep.values.length,
              currentStep: _currentStep.index + 1,
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 800;
             return isDesktop
              ? Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 800), child: _buildStepContent()))
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: _buildStepContent(),
              );
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 8.0 : 24.0,
          left: 24.0,
          right: 24.0,
          top: 12.0,
        ),
        child: Row(
          mainAxisAlignment: _currentStep == StoreConfigStep.paymentMethods
              ? MainAxisAlignment.end
              : MainAxisAlignment.spaceBetween,
          children: [
            if (_currentStep != StoreConfigStep.paymentMethods)
              Flexible(
                child: DsButton(
                  style: DsButtonStyle.secondary,
                  onPressed: _isLoading ? null : _goToPreviousStep,
                  label: 'Voltar',
                ),
              ),
            if (_currentStep != StoreConfigStep.paymentMethods)
              const SizedBox(width: 16),
            Flexible(
              child: DsButton(
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _goToNextStep,
                label: _currentStep == StoreConfigStep.menu ? 'IR PARA O PAINEL' : 'Continuar',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Constrói o conteúdo do passo atual
  Widget _buildStepContent() {
    switch (_currentStep) {
      case StoreConfigStep.paymentMethods:
        return PaymentMethodsPage(storeId: widget.storeId);
      case StoreConfigStep.deliveryArea:
        return CityNeighborhoodPage(storeId: widget.storeId, isInWizard: true,);
      case StoreConfigStep.openingHours:
        return OpeningHoursPage(key: _hoursKey, storeId: widget.storeId, isInWizard: true,);
      case StoreConfigStep.profile:
        return StoreProfilePage(key: _profileKey, storeId: widget.storeId, isInWizard: true);
      case StoreConfigStep.menu:
        return const FinalStepContent(); // Widget de finalização
    }
  }
}

// 3. Widget simples para o último passo
class FinalStepContent extends StatelessWidget {
  const FinalStepContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 60, color: Colors.green),
            SizedBox(height: 24),
            Text(
              'O próximo passo é adicionar seus produtos, categorias e complementos na seção "Cardápio" do painel principal.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}