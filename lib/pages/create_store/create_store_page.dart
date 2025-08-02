import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/pages/create_store/widgets/address_step.dart';
import 'package:totem_pro_admin/pages/create_store/widgets/business_details.dart';
import 'package:totem_pro_admin/pages/create_store/widgets/person_details.dart';
import 'package:totem_pro_admin/pages/create_store/widgets/plans_step.dart';
import 'package:totem_pro_admin/pages/create_store/widgets/progress_bar.dart';
import 'package:totem_pro_admin/pages/create_store/widgets/specialty_step.dart';
import 'package:totem_pro_admin/pages/create_store/widgets/store_details.dart';
import 'package:totem_pro_admin/pages/create_store/widgets/tax_id.dart';
import 'package:totem_pro_admin/pages/create_store/widgets/wizard_layout.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';

import '../../core/di.dart';
import '../../models/page_status.dart';
import '../../models/store.dart';
import 'cubit/store_setup-state.dart';
import 'cubit/store_setup_cubit.dart';


// 1. Adicione a nova etapa ao enum e reordene
enum SetupStep { storeDetails, address, taxId, specialty, businessDetails, personDetails, plans }

class StoreSetupPage extends StatefulWidget {

  const StoreSetupPage({super.key});

  @override
  State<StoreSetupPage> createState() => _StoreSetupPageState();
}

class _StoreSetupPageState extends State<StoreSetupPage> {
  // O estado inicial é a primeira etapa
  SetupStep _currentStep = SetupStep.storeDetails;

  // Cada etapa terá sua própria chave de formulário para validação
  final _formKeys = {
    SetupStep.storeDetails: GlobalKey<FormState>(),
    SetupStep.address: GlobalKey<FormState>(),
    SetupStep.specialty: GlobalKey<FormState>(),
    SetupStep.businessDetails: GlobalKey<FormState>(),
    SetupStep.personDetails: GlobalKey<FormState>(),
  };
  // --- Mapas de Conteúdo: Centraliza todos os textos em um só lugar ---
  final Map<SetupStep, double> _progressValues = {
    SetupStep.storeDetails: 0.0,
    SetupStep.address: 0.15,
    SetupStep.taxId: 0.3,
    SetupStep.specialty: 0.45,
    SetupStep.businessDetails: 0.6,
    SetupStep.personDetails: 0.75,
    SetupStep.plans: 1.0,
  };


  // 2. Atualize os mapas de conteúdo com a nova etapa
  final Map<SetupStep, String> _largeTitles = {
    SetupStep.storeDetails: 'Vamos criar sua loja!', // ✅ Adicionado
    SetupStep.address: 'Qual o endereço da sua loja?',
    SetupStep.taxId: 'Identificação do seu negócio',
    SetupStep.specialty: 'Qual a especialidade da sua loja?',
    SetupStep.businessDetails: 'Dados da sua empresa',
    SetupStep.personDetails: 'Quem é o responsável?',
    SetupStep.plans: 'Plano gratuito ativado',
  };


  final Map<SetupStep, String> _descriptions = {
    SetupStep.storeDetails: 'Digite o nome da sua loja para começar a configuração.', // ✅ Adicionado
    SetupStep.address: 'Precisamos saber onde sua loja está localizada para configurar as opções de entrega e retirada.',
    SetupStep.taxId: 'Selecione se você irá operar como pessoa jurídica (CNPJ) ou física (CPF).',
    SetupStep.specialty: 'Escolha a categoria principal da sua loja para personalizar sua experiência.',
    SetupStep.businessDetails: 'Informe os dados da sua empresa para emissão de notas e validação da sua conta.',
    SetupStep.personDetails: 'Precisamos dos dados da pessoa que será o contato principal e responsável pela loja.',
    SetupStep.plans: '',
  };

  final Map<SetupStep, String> sections = {
    SetupStep.storeDetails: 'CRIAR LOJA', // ✅ Adicionado
    SetupStep.address: 'ENDEREÇO DA LOJA',
    SetupStep.taxId: 'INFORMAÇÕES DA LOJA',
    SetupStep.specialty: 'ESPECIALIDADE DA LOJA',
    SetupStep.businessDetails: 'SOBRE A LOJA',
    SetupStep.personDetails: 'RESPONSÁVEL',
    SetupStep.plans: 'PLANO ATUAL',
  };


// 3. Atualize a lógica de navegação
  void _goToNextStep() {


    if (_formKeys[_currentStep]?.currentState?.validate() ?? true) {

      // Se a etapa atual for a de Planos, chama o método de submissão
      if (_currentStep == SetupStep.plans) {
        // ✅ ADICIONE ESTA CHAMADA AQUI
        context.read<StoreSetupCubit>().submitStoreSetup();
        return; // Retorna para não executar o switch abaixo
      }


      final cubit = context.read<StoreSetupCubit>();
      setState(() {

        switch (_currentStep) {
          case SetupStep.storeDetails:
            _currentStep = SetupStep.address;
            break;
          case SetupStep.address:
            _currentStep = SetupStep.taxId;
            break;
          case SetupStep.taxId:
            _currentStep = SetupStep.specialty;
            break;
          case SetupStep.specialty:
            _currentStep = cubit.state.taxIdType == TaxIdType.cnpj
                ? SetupStep.businessDetails
                : SetupStep.personDetails;
            break;
          case SetupStep.businessDetails:
            _currentStep = SetupStep.personDetails;
            break;
          case SetupStep.personDetails:
            _currentStep = SetupStep.plans;
            break;
          case SetupStep.plans:
            // TODO: Handle this case.
            throw UnimplementedError();
        }
      });
    }
  }

  void _goToPreviousStep() {
    final cubit = context.read<StoreSetupCubit>();
    setState(() {
      switch (_currentStep) {
        case SetupStep.taxId:
          _currentStep = SetupStep.address;
          break;
        case SetupStep.specialty:
          _currentStep = SetupStep.taxId;
          break;
        case SetupStep.businessDetails:
          _currentStep = SetupStep.specialty;
          break;
        case SetupStep.personDetails:
          _currentStep = cubit.state.taxIdType == TaxIdType.cnpj
              ? SetupStep.businessDetails
              : SetupStep.specialty;
          break;
        case SetupStep.plans:
          _currentStep = SetupStep.personDetails;
          break;
        case SetupStep.address:
          _currentStep = SetupStep.storeDetails;
          break;
        case SetupStep.storeDetails:
          break;
      }
    });
  }



// Dentro de _StoreSetupPageState
  @override
  Widget build(BuildContext context) {
    // ✅ ENVOLVA SEU SCAFFOLD COM UM BLOCLISTENER
    return BlocListener<StoreSetupCubit, StoreSetupState>(
      listenWhen: (previous, current) => previous.submissionStatus != current.submissionStatus,
      listener: (context, state) {
        final status = state.submissionStatus;

        // Se estiver carregando, mostra um dialog
        if (status is PageStatusLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: DotLoading()),
          );
        }

        // Se der erro, fecha o dialog e mostra um SnackBar
        if (status is PageStatusError) {
          Navigator.of(context, rootNavigator: true).pop(); // Fecha o dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(status.message), backgroundColor: Colors.red),
          );
        }

        // Se der sucesso, fecha o dialog, mostra SnackBar e navega
        if (status is PageStatusSuccess) {
          Navigator.of(context, rootNavigator: true).pop(); // Fecha o dialog
          final newStore = status.data as Store;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Loja criada com sucesso!'), backgroundColor: Colors.green),
          );

          context.go('/stores/${newStore.id}/orders');
        }
      },
      child:  Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8.0),
          // 👇 SUBSTITUA O LinearProgressIndicator AQUI 👇
          child: BlocBuilder<StoreSetupCubit, StoreSetupState>(
            builder: (context, state) {
              // Lógica para saber o número total de passos
              final totalSteps = state.taxIdType == TaxIdType.cnpj ? 5 : 4;
              // Pega o índice do passo atual
              final currentStepIndex = _currentStep.index + 1;

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

            sectionTitle: sections[_currentStep]!,
            child: _buildStepForm(), // Constrói o formulário da etapa atual
          );

          if (isDesktop) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: wizardCard,
              ),
            );
          }
          return wizardCard;
        },
      ),

      bottomNavigationBar:
      Wrap(

        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botão de voltar (só aparece se onBack não for nulo)

                TextButton(
                  onPressed: _currentStep == SetupStep.storeDetails ? null : _goToPreviousStep,
                  child: const Text('‹ Voltar'),
                ),


                // Botão de continuar
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: _goToNextStep,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(250, 48), // Tamanho grande
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Pouco radius
                      ),
                    ),
                    child: Text(
                      _currentStep == SetupStep.plans ? 'Finalizar e Ativar' : 'Continuar',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),


              ],
            ),
          ),
        ],
      ),
    ),
    );
  }















  Widget _buildStepForm() {
    switch (_currentStep) {
      case SetupStep.storeDetails:
        return StoreDetailsStep(formKey: _formKeys[SetupStep.storeDetails]!); // ou seu widget da primeira etapa
      case SetupStep.address:
        return AddressStep(formKey: _formKeys[SetupStep.address]!);
      case SetupStep.taxId:
        return const TaxIdStep();
      case SetupStep.specialty:
        return SpecialtyStep(formKey: _formKeys[SetupStep.specialty]!); // ✅ NOVO
      case SetupStep.businessDetails:
        return BusinessDetailsStep(formKey: _formKeys[SetupStep.businessDetails]!);
      case SetupStep.personDetails:
        return PersonDetailsStep(formKey: _formKeys[SetupStep.personDetails]!);
      case SetupStep.plans:
        return const PlansStep();
    }
  }

}

