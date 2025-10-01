import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/page_status.dart';
import 'package:totem_pro_admin/models/store/store.dart';
import 'package:totem_pro_admin/pages/create_store/cubit/store_setup-state.dart';
import 'package:totem_pro_admin/pages/create_store/cubit/store_setup_cubit.dart';
import 'package:totem_pro_admin/pages/create_store/widgets/address_step.dart';
import 'package:totem_pro_admin/pages/create_store/widgets/business_details.dart';
import 'package:totem_pro_admin/pages/create_store/widgets/contract_step.dart';
import 'package:totem_pro_admin/pages/create_store/widgets/person_details.dart';
import 'package:totem_pro_admin/pages/create_store/widgets/plans_step.dart';
import 'package:totem_pro_admin/pages/create_store/widgets/progress_bar.dart';
import 'package:totem_pro_admin/pages/create_store/widgets/specialty_step.dart';
import 'package:totem_pro_admin/pages/create_store/widgets/store_details.dart';
import 'package:totem_pro_admin/pages/create_store/widgets/submission_animation_page.dart';
import 'package:totem_pro_admin/pages/create_store/widgets/tax_id.dart';
import 'package:totem_pro_admin/pages/create_store/widgets/wizard_layout.dart';

import '../../widgets/ds_primary_button.dart';

enum SetupStep { storeDetails, address, taxId, specialty, businessDetails, personDetails, plans, contract }

class StoreSetupPage extends StatefulWidget {

  const StoreSetupPage({super.key});

  @override
  State<StoreSetupPage> createState() => _StoreSetupPageState();
}

class _StoreSetupPageState extends State<StoreSetupPage> {


  SetupStep _currentStep = SetupStep.storeDetails;

  final _formKeys = {
    SetupStep.storeDetails: GlobalKey<FormState>(),
    SetupStep.address: GlobalKey<FormState>(),
    SetupStep.specialty: GlobalKey<FormState>(),
    SetupStep.businessDetails: GlobalKey<FormState>(),
    SetupStep.personDetails: GlobalKey<FormState>(),
  };

  final GlobalKey<ContractStepState> _contractStepKey = GlobalKey<ContractStepState>();

  final Map<SetupStep, String> _largeTitles = {
    SetupStep.storeDetails: 'Vamos criar sua loja!',
    SetupStep.address: 'Qual o endereço da sua loja?',
    SetupStep.taxId: 'Identificação do seu negócio',
    SetupStep.specialty: 'Qual a especialidade da sua loja?',
    SetupStep.businessDetails: 'Dados da sua empresa',
    SetupStep.personDetails: 'Quem é o responsável?',
    SetupStep.plans: 'Plano Único ativado',
    SetupStep.contract: 'Termos e Condições de Uso',
  };

  final Map<SetupStep, String> _descriptions = {
    SetupStep.storeDetails: 'Digite o nome da sua loja para começar a configuração.',
    SetupStep.address: 'Precisamos saber onde sua loja está localizada...',
    SetupStep.taxId: 'Selecione se você irá operar como pessoa jurídica (CNPJ) ou física (CPF).',
    SetupStep.specialty: 'Escolha a categoria principal da sua loja...',
    SetupStep.businessDetails: 'Informe os dados da sua empresa...',
    SetupStep.personDetails: 'Precisamos dos dados da pessoa responsável...',
    SetupStep.plans: 'Seu plano inicial foi ativado. Revise os termos para finalizar.',
    SetupStep.contract: 'Leia atentamente os termos do contrato. Ao assinar, você concorda com todas as cláusulas.',
  };

  final Map<SetupStep, String> _sections = {
    SetupStep.storeDetails: 'CRIAR LOJA',
    SetupStep.address: 'ENDEREÇO DA LOJA',
    SetupStep.taxId: 'INFORMAÇÕES DA LOJA',
    SetupStep.specialty: 'ESPECIALIDADE DA LOJA',
    SetupStep.businessDetails: 'SOBRE A LOJA',
    SetupStep.personDetails: 'RESPONSÁVEL',
    SetupStep.plans: 'PLANO ATUAL',
    SetupStep.contract: 'CONTRATO', // ✅ CORREÇÃO: Chave que faltava
  };

  Future<void> _finalSubmit() async {



    final cubit = context.read<StoreSetupCubit>();


    await cubit.submitStoreSetup();
  }

  void _goToNextStep() {
    if (_formKeys[_currentStep]?.currentState?.validate() ?? true) {
      if (_currentStep == SetupStep.contract) {
        _finalSubmit();
        return;
      }

      final cubit = context.read<StoreSetupCubit>();
      final nextStep = _getNextStep(_currentStep, cubit.state.taxIdType);

      setState(() {
        _currentStep = nextStep;
      });
    }
  }

// ✅ MÉTODO AUXILIAR PARA CALCULAR PRÓXIMO STEP
  SetupStep _getNextStep(SetupStep currentStep, TaxIdType taxIdType) {
    switch (currentStep) {
      case SetupStep.storeDetails:
        return SetupStep.address;
      case SetupStep.address:
        return SetupStep.taxId;
      case SetupStep.taxId:
        return SetupStep.specialty;
      case SetupStep.specialty:
        return taxIdType == TaxIdType.cnpj
            ? SetupStep.businessDetails
            : SetupStep.personDetails;
      case SetupStep.businessDetails:
        return SetupStep.personDetails;
      case SetupStep.personDetails:
        return SetupStep.plans;
      case SetupStep.plans:
        return SetupStep.contract;
      case SetupStep.contract:
        return SetupStep.contract;
    }
  }
  void _goToPreviousStep() {
    final cubit = context.read<StoreSetupCubit>();
    final previousStep = _getPreviousStep(_currentStep, cubit.state.taxIdType);

    setState(() {
      _currentStep = previousStep;
    });
  }

// ✅ MÉTODO AUXILIAR PARA CALCULAR STEP ANTERIOR
  SetupStep _getPreviousStep(SetupStep currentStep, TaxIdType taxIdType) {
    switch (currentStep) {
      case SetupStep.storeDetails:
        return SetupStep.storeDetails;
      case SetupStep.address:
        return SetupStep.storeDetails;
      case SetupStep.taxId:
        return SetupStep.address;
      case SetupStep.specialty:
        return SetupStep.taxId;
      case SetupStep.businessDetails:
        return SetupStep.specialty;
      case SetupStep.personDetails:
        return taxIdType == TaxIdType.cnpj
            ? SetupStep.businessDetails
            : SetupStep.specialty;
      case SetupStep.plans:
        return SetupStep.personDetails;
      case SetupStep.contract:
        return SetupStep.plans;
    }
  }



  @override
  Widget build(BuildContext context) {
    return BlocListener<StoreSetupCubit, StoreSetupState>(
      listenWhen: (previous, current) => previous.submissionStatus != current.submissionStatus,
      listener: (context, state) {
        final status = state.submissionStatus;
        if (status is PageStatusLoading) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => SubmissionAnimationPage(storeSetupCubit: context.read<StoreSetupCubit>())),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,


          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(8.0),
            child: BlocBuilder<StoreSetupCubit, StoreSetupState>(
              builder: (context, state) {
                // ✅ CORREÇÃO: Calcula dinamicamente baseado no tipo de documento
                final totalSteps = _calculateTotalSteps(state.taxIdType);
                final currentStepIndex = _calculateCurrentStepIndex(_currentStep, state.taxIdType);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SegmentedProgressBar(
                    totalSteps: totalSteps,
                    currentStep: currentStepIndex,
                  ),
                );
              },
            ),
          ),





        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 800;
            Widget wizardCard = WizardStepLayout(
              largeTitle: _largeTitles[_currentStep]!,
              description: _descriptions[_currentStep]!,
              sectionTitle: _sections[_currentStep]!,
              child: _buildStepForm(),
            );

            return isDesktop
                ? Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 600), child: wizardCard))
                : wizardCard;
          },
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom > 0
                ? 8.0  // Menos padding quando teclado está aberto
                : 18.0, // Padding normal
            left: 18.0,
            right: 18.0,
            top: 12.0,
          ),

          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                if(_currentStep != SetupStep.storeDetails)
                Flexible(
                  child: DsButton(
                    requiresConnection: false,
                    style: DsButtonStyle.secondary,
                    onPressed: _currentStep == SetupStep.storeDetails ? null : _goToPreviousStep,
                    label: 'Voltar',
                  ),
                ),

                const SizedBox(width: 18),
                Flexible(
                  child: DsButton(
                    requiresConnection: false,
                    onPressed: _goToNextStep,
                    label: _currentStep == SetupStep.contract ? 'ACEITAR E FINALIZAR' : 'Continuar',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepForm() {
    return switch (_currentStep) {
      SetupStep.storeDetails => StoreDetailsStep(formKey: _formKeys[SetupStep.storeDetails]!),
      SetupStep.address => AddressStep(formKey: _formKeys[SetupStep.address]!),
      SetupStep.taxId => const TaxIdStep(),
      SetupStep.specialty => SpecialtyStep(formKey: _formKeys[SetupStep.specialty]!),
      SetupStep.businessDetails => BusinessDetailsStep(formKey: _formKeys[SetupStep.businessDetails]!),
      SetupStep.personDetails => PersonDetailsStep(formKey: _formKeys[SetupStep.personDetails]!),
      SetupStep.plans => const PlansStep(),
      SetupStep.contract => ContractStep(key: _contractStepKey),
    };
  }

  // ✅ ADICIONE ESTES MÉTODOS AUXILIARES:
  int _calculateTotalSteps(TaxIdType taxIdType) {
    return taxIdType == TaxIdType.cnpj ? 8 : 7;
  }

  int _calculateCurrentStepIndex(SetupStep currentStep, TaxIdType taxIdType) {
    final allSteps = [
      SetupStep.storeDetails,
      SetupStep.address,
      SetupStep.taxId,
      SetupStep.specialty,
      if (taxIdType == TaxIdType.cnpj) SetupStep.businessDetails,
      SetupStep.personDetails,
      SetupStep.plans,
      SetupStep.contract,
    ];

    return allSteps.indexOf(currentStep) + 1;
  }
}