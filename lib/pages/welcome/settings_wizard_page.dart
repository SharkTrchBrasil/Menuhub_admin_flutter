

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/responsive_builder.dart';
import '../../cubits/store_manager_cubit.dart';
import '../../cubits/store_manager_state.dart';

import '../edit_settings/general/store_profile_page.dart';
import '../edit_settings/hours/hours_store_page.dart';
import '../platform_payment_methods/gateway-payment.dart';
import '../products/products_page.dart';



class OnboardingWizardPage extends StatefulWidget {
  final int storeId;
  const OnboardingWizardPage({super.key, required this.storeId});

  @override
  State<OnboardingWizardPage> createState() => _OnboardingWizardPageState();
}





class _OnboardingWizardPageState extends State<OnboardingWizardPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isSaving = false; // ✅ 3. VARIÁVEL DE ESTADO ADICIONADA

  // ✅ 1. REATIVE A KEY DO PRODUTO
  final _profilePageKey = GlobalKey<StoreProfilePageState>();
  final _hoursPageKey = GlobalKey<OpeningHoursPageState>();
  final _productPageKey = GlobalKey<CategoryProductPageState>(); // <-- MUDANÇA AQUI


  // A lista de títulos permanece a mesma
  late final List<String> _pageTitles;

  @override
  void initState() {
    super.initState();
    _pageTitles = [
      'Informações da Loja',
      'Horários de Funcionamento',
      'Formas de Pagamento',
      'Cadastre um Produto',
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    setState(() { _isSaving = true; });

    bool savedSuccessfully = false;

    switch (_currentStep) {
      case 0:
      // ✅ ADICIONE ESTES PRINTS
        print("WIZARD: Tentando salvar a página de perfil...");
        savedSuccessfully = await _profilePageKey.currentState?.save() ?? false;
        print("WIZARD: Resultado do salvamento do perfil: $savedSuccessfully");
        break;
      case 1:
      // Adicione prints aqui também se o problema for no passo 2
        print("WIZARD: Tentando salvar a página de horários...");
        savedSuccessfully = await _hoursPageKey.currentState?.save() ?? false;
        print("WIZARD: Resultado do salvamento dos horários: $savedSuccessfully");
        break;
      case 2:
        savedSuccessfully = true;
        break;

    // ✅ LÓGICA DO ÚLTIMO PASSO ATUALIZADA
      case 3:
        print("WIZARD: Verificando se o cardápio tem conteúdo...");
        // Chama o novo método `hasContent()` para validar o passo
        final contentExists = await _productPageKey.currentState?.hasContent() ?? false;
        print("WIZARD: Conteúdo existe? $contentExists");

        // O "sucesso" deste passo é ter ao menos uma categoria.
        savedSuccessfully = contentExists;
        break;
    }

    // Atraso para o usuário perceber o feedback de salvamento antes de prosseguir
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) {
      setState(() { _isSaving = false; });
      return;
    }

    if (savedSuccessfully) {
      // ✅ 2. CORRIGIDO PARA USAR _pageTitles.length
      if (_currentStep < _pageTitles.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuração finalizada com sucesso!'), backgroundColor: Colors.green),
        );
        // ✅ 5. REATIVE A FINALIZAÇÃO DO ONBOARDING
       // context.read<StoresManagerCubit>().reloadActiveStore();
        context.go('/stores/${widget.storeId}/dashboard');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha os campos corretamente para continuar.')),
      );
    }

    setState(() { _isSaving = false; });
  }

  void _onBack() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded || state.activeStore == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final activeStore = state.activeStore!;

        // A lista de páginas é construída aqui, com os dados mais recentes
        final List<Widget> pages = [
          StoreProfilePage(
            key: _profilePageKey,
            storeId: widget.storeId,
            isInWizard: true,
          ),
          OpeningHoursPage(
            key: _hoursPageKey,
            storeId: widget.storeId,
            isInWizard: true,
          ),
          PlatformPaymentMethodsPage(
            storeId: widget.storeId,
            isInWizard: true,
          ),
          // ✅ 1. REATIVE A PÁGINA DE PRODUTO
          // ✅ SUBSTITUA A PÁGINA ANTIGA PELA `CategoryProductPage`
          CategoryProductPage(
            key: _productPageKey,
            storeId: widget.storeId,
          ),
        ];

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(_pageTitles[_currentStep]),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(30.0),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / pages.length,
                ),
              ),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveBuilder.isMobile(context) ? 8 :28.0, vertical: 18),
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) => setState(() => _currentStep = page),
              children: pages,
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(onPressed: _onBack, child: const Text('Voltar'))
                  else
                    const SizedBox(),
                  ElevatedButton(

                    onPressed: _isSaving ? null : _onNext,
                    child: _isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_currentStep == pages.length - 1 ? 'Finalizar' : 'Continuar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
class PlaceholderStepPage extends StatelessWidget {
  final String title;
  final Color color;

  const PlaceholderStepPage({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}