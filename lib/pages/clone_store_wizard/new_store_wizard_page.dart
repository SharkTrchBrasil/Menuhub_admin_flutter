import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/models/page_status.dart';
import 'package:totem_pro_admin/pages/create_store/widgets/address_step.dart';
import 'package:totem_pro_admin/pages/create_store/widgets/store_details.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';

import '../../core/di.dart';
import '../../core/enums/wizard_type.dart';
import 'clone_options_step.dart';
import 'cubit/new_store_cubit.dart';
import 'cubit/new_store_state.dart';
class NewStoreWizardPage extends StatelessWidget {
  final WizardMode mode;

  const NewStoreWizardPage({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {

    return BlocProvider<NewStoreCubit>(
      create: (context) => getIt<NewStoreCubit>()..init(mode),
      child: const _NewStoreWizardView(),
    );
  }
}
class _NewStoreWizardView extends StatefulWidget {
  const _NewStoreWizardView();

  @override
  State<_NewStoreWizardView> createState() => _NewStoreWizardViewState();
}

class _NewStoreWizardViewState extends State<_NewStoreWizardView> {
  final PageController _pageController = PageController();

  // ✅ 1. Definimos as chaves do formulário aqui, uma vez.
  final _detailsFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();

  // ✅ 2. A lista de steps é definida com base no modo.
  List<Widget> _getSteps(WizardMode mode) {
    final standardSteps = [
      StoreDetailsStep(formKey: _detailsFormKey),
      AddressStep(formKey: _addressFormKey),
    ];

    if (mode == WizardMode.clone) {
      return [
        ...standardSteps,
        const CloneOptionsStep(),
      ];
    }
    return standardSteps;
  }

  void _onPageChanged(int newPage) {
    context.read<NewStoreCubit>().updateStep(newPage);
  }

  void _goToNextStep(int currentStep, int totalSteps) {
    // Valida o formulário do passo atual antes de avançar
    bool isValid = true;
    if (currentStep == 0) {
      isValid = _detailsFormKey.currentState?.validate() ?? false;
    } else if (currentStep == 1) {
      isValid = _addressFormKey.currentState?.validate() ?? false;
    }

    if (isValid) {
      if (currentStep < totalSteps - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        context.read<NewStoreCubit>().submit();
      }
    }
  }

  void _goToPreviousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NewStoreCubit, NewStoreState>(
      listener: (context, state) {
        final submissionStatus = state.submissionStatus;
        if (submissionStatus is PageStatusSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Loja criada com sucesso! Redirecionando...'), backgroundColor: Colors.green),
          );
          // Adiciona a nova loja ao StoreManagerCubit e navega
          context.read<StoresManagerCubit>().addNewStore(submissionStatus.data);
          context.go('/stores/${submissionStatus.data.store.core.id}/wizard');
        }
        if (submissionStatus is PageStatusError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(submissionStatus.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state.status is PageStatusLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (state.status is PageStatusError) {
          return Scaffold(body: Center(child: Text((state.status as PageStatusError).message)));
        }

        final steps = _getSteps(state.mode);

        return Scaffold(
          appBar: AppBar(
            title: Text(state.mode == WizardMode.clone ? 'Clonar Loja' : 'Criar Nova Loja'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: LinearProgressIndicator(
                value: (state.currentStep + 1) / steps.length,
                backgroundColor: Colors.grey[200],
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14),
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: _onPageChanged,
              children: steps,
            ),
          ),
          bottomNavigationBar: _buildBottomNavBar(state, steps.length),
        );
      },
    );
  }

  Widget _buildBottomNavBar(NewStoreState state, int totalSteps) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (state.currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _goToPreviousStep,
                  child: const Text('Voltar'),
                ),
              ),
            if (state.currentStep > 0) const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: state.submissionStatus is PageStatusLoading
                    ? null
                    : () => _goToNextStep(state.currentStep, totalSteps),
                child: state.submissionStatus is PageStatusLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(state.currentStep == totalSteps - 1 ? 'Finalizar' : 'Continuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}