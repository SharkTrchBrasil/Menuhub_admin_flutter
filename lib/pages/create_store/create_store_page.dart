import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/page_status.dart';
import 'package:totem_pro_admin/models/store.dart';
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
    SetupStep.plans: 'Plano gratuito ativado',
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
    final signatureController = _contractStepKey.currentState?.signatureController;

    if (signatureController == null || signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('É necessário assinar o contrato para continuar.')),
      );
      return;
    }

    final signatureBytes = await signatureController.toPngBytes();
    if (signatureBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível capturar a assinatura.')),
      );
      return;
    }

    final signatureBase64 = base64Encode(signatureBytes);
    final cubit = context.read<StoreSetupCubit>();
    cubit.emit(cubit.state.copyWith(signatureBase64: signatureBase64));

    // Dispara a submissão para o backend
    await cubit.submitStoreSetup();
  }

  void _goToNextStep() {
    // 1. Valida o formulário da etapa atual (se houver)
    if (_formKeys[_currentStep]?.currentState?.validate() ?? true) {

      // 2. Se a etapa atual for o contrato, chama a submissão final
      if (_currentStep == SetupStep.contract) {
        _finalSubmit();
        return;
      }

      // 3. Se não for, apenas avança para a próxima etapa
      final cubit = context.read<StoreSetupCubit>();
      setState(() {
        _currentStep = switch (_currentStep) {
          SetupStep.storeDetails => SetupStep.address,
          SetupStep.address => SetupStep.taxId,
          SetupStep.taxId => SetupStep.specialty,
          SetupStep.specialty => cubit.state.taxIdType == TaxIdType.cnpj
              ? SetupStep.businessDetails
              : SetupStep.personDetails,
          SetupStep.businessDetails => SetupStep.personDetails,
          SetupStep.personDetails => SetupStep.plans,
          SetupStep.plans => SetupStep.contract,
          SetupStep.contract => _currentStep,
        };
      });
    }
  }

  void _goToPreviousStep() {
    final cubit = context.read<StoreSetupCubit>();
    setState(() {
      _currentStep = switch (_currentStep) {
        SetupStep.storeDetails => _currentStep,
        SetupStep.address => SetupStep.storeDetails,
        SetupStep.taxId => SetupStep.address,
        SetupStep.specialty => SetupStep.taxId,
        SetupStep.businessDetails => SetupStep.specialty,
        SetupStep.personDetails => cubit.state.taxIdType == TaxIdType.cnpj
            ? SetupStep.businessDetails
            : SetupStep.specialty,
        SetupStep.plans => SetupStep.personDetails,
        SetupStep.contract => SetupStep.plans,
      };
    });
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
                final totalSteps = state.taxIdType == TaxIdType.cnpj ? 8 : 7; // Agora são 8 ou 7 passos
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SegmentedProgressBar(
                    totalSteps: totalSteps,
                    currentStep: _currentStep.index + 1,
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
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _currentStep == SetupStep.storeDetails ? null : _goToPreviousStep,
                child: const Text('‹ Voltar'),
              ),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _goToNextStep,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(250, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    _currentStep == SetupStep.contract ? 'ACEITAR E FINALIZAR' : 'Continuar',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
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
}