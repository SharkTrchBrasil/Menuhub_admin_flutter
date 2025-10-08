import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/pages/edit_settings/citys/delivery_locations_page.dart';
import 'package:totem_pro_admin/pages/edit_settings/general/store_profile_page.dart';
import 'package:totem_pro_admin/pages/edit_settings/hours/hours_store_page.dart';
import 'package:totem_pro_admin/pages/edit_settings/payment_methods/payment_methods_page.dart';
import 'package:totem_pro_admin/pages/products/products_page.dart';
import 'package:totem_pro_admin/pages/store_wizard/widgets/finish_step_content.dart';
import 'package:totem_pro_admin/pages/store_wizard/widgets/progress_bar.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';

import 'cubit/store_wizard_cubit.dart';

enum StoreConfigStep {
  profile,
  paymentMethods,
  deliveryArea,
  openingHours,
  productCatalog,
  finish,
}

// ✅ ETAPA 1: O WIDGET PRINCIPAL AGORA CRIA O BLOCPROVIDER
class StoreSetupWizardPage extends StatelessWidget {
  final int storeId;
  const StoreSetupWizardPage({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    // O BlocProvider é movido para cá. Ele será criado uma vez e
    // permanecerá vivo enquanto a página do wizard estiver na árvore de widgets.
    return BlocProvider(
      create: (context) => StoreWizardCubit(
        storeId: storeId,
        storesManagerCubit: context.read<StoresManagerCubit>(),
      ),
      // A View agora é apenas um consumidor do Bloc.
      child: const _StoreSetupWizardView(),
    );
  }
}

// ✅ ETAPA 2: A VIEW SE TORNA UM WIDGET MAIS SIMPLES SEM ESTADO INTERNO
class _StoreSetupWizardView extends StatelessWidget {
  const _StoreSetupWizardView();

  @override
  Widget build(BuildContext context) {
    // O BlocBuilder escuta o Cubit fornecido pelo BlocProvider acima.
    // Ele não precisa mais receber o storeId, pois o Cubit já o possui.
    return BlocBuilder<StoreWizardCubit, StoreWizardState>(
      builder: (context, state) {
        if (state is StoreWizardLoading || state is StoreWizardInitial) {
          return const _LoadingState();
        }

        if (state is StoreWizardError) {
          return _ErrorState(message: state.message);
        }

        if (state is StoreWizardLoaded) {
          return _WizardContent(state: state);
        }

        return const SizedBox.shrink();
      },
    );
  }
}



class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: const DotLoading(),
      ),
    );
  }
}




class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
                'Erro ao carregar',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _WizardContent extends StatelessWidget {
  final StoreWizardLoaded state;
  const _WizardContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StoreWizardCubit>();
    final isFinalStep = state.currentStep == StoreConfigStep.finish;

    return Scaffold(
      appBar: _WizardAppBar(
        state: state,
        onStepTapped: (step) => cubit.goToStep(step),
      ),
      body: _ResponsiveWizardBody(
        state: state,
        cubit: cubit,
      ),
      bottomNavigationBar: _WizardBottomBar(
        state: state,
        cubit: cubit,
        isFinalStep: isFinalStep,
      ),
    );
  }
}

class _WizardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final StoreWizardLoaded state;
  final Function(StoreConfigStep) onStepTapped;

  const _WizardAppBar({required this.state, required this.onStepTapped});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Configure sua Loja',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StoreWizardProgressBar(

                stepStatus: state.stepCompletionStatus,
                currentStepIndex: state.currentStep.index,
                onStepTapped: onStepTapped,
              ),
              const SizedBox(height: 8),
              _StepIndicator(state: state),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final StoreWizardLoaded state;

  const _StepIndicator({required this.state});

  @override
  Widget build(BuildContext context) {
    final workSteps = StoreConfigStep.values.where((s) => s != StoreConfigStep.finish).length;
    final currentStepNumber = state.currentStep.index + 1;

    String stepText;
    if (state.currentStep == StoreConfigStep.finish) {
      stepText = 'Configuração Concluída!';
    } else {
      stepText = 'Etapa $currentStepNumber de $workSteps';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [

        Text(
          stepText,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

}

class _ResponsiveWizardBody extends StatelessWidget {
  final StoreWizardLoaded state;
  final StoreWizardCubit cubit;

  const _ResponsiveWizardBody({
    required this.state,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 1024;
        final isTablet = constraints.maxWidth > 600;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 1000 : (isTablet ? 800 : 500),
            ),
            child: _AnimatedStepContent(
              step: state.currentStep,
              cubit: cubit,
              storeId: state.store.core.id!,
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedStepContent extends StatelessWidget {
  final StoreConfigStep step;
  final StoreWizardCubit cubit;
  final int storeId;

  const _AnimatedStepContent({
    required this.step,
    required this.cubit,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: Container(
        key: ValueKey(step),
        child: _buildStepContent(step, cubit, storeId),
      ),
    );
  }

  Widget _buildStepContent(StoreConfigStep step, StoreWizardCubit cubit, int storeId) {
    final content = switch (step) {
      StoreConfigStep.profile => StoreProfilePage(
        key: cubit.profileKey,
        storeId: storeId,
        isInWizard: true,
      ),
      StoreConfigStep.paymentMethods => PaymentMethodsPage(storeId: storeId),
      StoreConfigStep.deliveryArea => CityNeighborhoodPage(
        storeId: storeId,
        isInWizard: true,
      ),
      StoreConfigStep.openingHours => OpeningHoursPage(
        key: cubit.hoursKey,
        storeId: storeId,
        isInWizard: true,
      ),
      StoreConfigStep.productCatalog => CategoryProductPage(
        key: cubit.catalogKey,
        storeId: storeId,
        isInWizard: true,
      ),
      StoreConfigStep.finish => const FinishStepContent(),
    };

    return content;
  }
}

class _WizardBottomBar extends StatelessWidget {
  final StoreWizardLoaded state;
  final StoreWizardCubit cubit;
  final bool isFinalStep;

  const _WizardBottomBar({
    required this.state,
    required this.cubit,
    required this.isFinalStep,
  });

  @override
  Widget build(BuildContext context) {
    final isFirstStep = state.currentStep.index == 0;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12, width: 1)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 8.0 : 24.0,
        left: 24.0,
        right: 24.0,
        top: 16.0,
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Botão Voltar
            if (!isFirstStep)
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: !state.isLoadingAction
                      ? DsButton(
                    key: const ValueKey('back_button'),
                    style: DsButtonStyle.secondary,
                    onPressed: cubit.goToPreviousStep,
                    label: 'Voltar',
                  )
                      : const SizedBox.shrink(),
                ),
              )
            else
              const Spacer(),

            const SizedBox(width: 16),

            // Botão Continuar/Concluir
            Flexible(
              child: DsButton(
                isLoading: state.isLoadingAction,
                onPressed: state.isLoadingAction
                    ? null
                    : () => isFinalStep
                    ? cubit.finishSetup(context)
                    : cubit.goToNextStep(),
                label: isFinalStep ? 'IR PARA O PAINEL' : 'Continuar',
              ),
            ),
          ],
        ),
      ),
    );
  }
}