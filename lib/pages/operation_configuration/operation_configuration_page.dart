// Salve como: pages/edit_settings/tabs/operation_configuration_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/store_operation_config.dart'; // Importe o modelo correto
import 'package:totem_pro_admin/repositories/store_operation_config_repository.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/fixed_header.dart';
import 'package:totem_pro_admin/widgets/mobileappbar.dart';
import 'dart:developer';

import '../../../core/di.dart';
import '../../../repositories/store_repository.dart'; // Ou o repo correto
import '../../../widgets/app_counter_form_field.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_toasts.dart';
import '../../widgets/app_toasts.dart' as AppToasts;
import '../base/BasePage.dart';


// ✅ Nome da classe atualizado
class OperationConfigurationPage extends StatefulWidget {
  final int storeId;

  const OperationConfigurationPage({super.key, required this.storeId});

  @override
  State<OperationConfigurationPage> createState() => _OperationConfigurationPageState();
}

class _OperationConfigurationPageState extends State<OperationConfigurationPage> {
  // ✅ Repositório usado apenas para salvar
  final StoreOperationConfigRepository storeRepository = getIt(); // Adapte se criou um repo novo
  final formKey = GlobalKey<FormState>();

  // ✅ Estado local para edição, sem controller complexo
  StoreOperationConfig? _editableConfig;
  int? _storeIdForSync;
  DateTime? _lastUpdateFromCubit;

  // ✅ Lógica de salvar agora é centralizada e simples
  Future<void> _save() async {
    if (formKey.currentState?.validate() != true || _editableConfig == null) return;

    final l = showLoading();
    // ✅ Chame o novo método do repositório
    final result = await storeRepository.updateConfiguration(widget.storeId, _editableConfig!);
    l();

    result.fold(
          (error) => AppToasts.showError('Erro ao salvar configurações.'),
          (success) {
        AppToasts.showSuccess('Configurações de operação salvas!');
        // A UI atualizará sozinha via socket.
      },
    );
  }

  // ✅ Callback para atualizar o estado local
  void _onConfigChanged(StoreOperationConfig newConfig) {
    setState(() {
      _editableConfig = newConfig;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      bottomNavigationBar:   Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              child: AppPrimaryButton(


                onPressed: _save,
                label: 'Salvar Alterações',

              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: formKey,

        child: _buildPageContent(isMobile: false),


        // BasePage(
        //
        //
        //   desktopBuilder: (context) => _buildPageContent(isMobile: false),
        //   mobileBuilder: (context) => _buildPageContent(isMobile: true),
        //
        //
        // ),
      ),
    );
  }

  Widget _buildPageContent({required bool isMobile}) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final activeStore = state.activeStore;
        final configFromCubit = activeStore?.relations.storeOperationConfig;

        if (configFromCubit == null) {
          return const Center(child: Text("Configurações de operação não encontradas."));
        }

        if (_storeIdForSync != activeStore!.core.id || _lastUpdateFromCubit != state.lastUpdate) {
          log('🔄 Sincronizando UI de Configuração de Operação com dados do Cubit...');
          _storeIdForSync = activeStore.core.id;
          _lastUpdateFromCubit = state.lastUpdate;
          _editableConfig = configFromCubit.copyWith();
        }

        if (_editableConfig == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SizedBox(height: 30,),
                    // SEÇÃO 1 - MODO DE ENTREGA
                    const Text('Modo de Entrega', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Selecione os modos de atendimento disponíveis', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),

                    _buildServiceOption(context,
                      // ✅ Lendo do estado local
                      value: _editableConfig!.deliveryEnabled,
                      // ✅ Atualizando o estado local
                      onChanged: (v) => _onConfigChanged(_editableConfig!.copyWith(deliveryEnabled: v ?? false)),
                      title: 'Entrega',
                      description: 'O pedido chega até o cliente por um entregador',
                    ),
                    _buildServiceOption(context,
                      value: _editableConfig!.pickupEnabled,
                      onChanged: (v) => _onConfigChanged(_editableConfig!.copyWith(pickupEnabled: v ?? false)),
                      title: 'Retirada na loja',
                      description: 'O cliente retira o pedido no balcão da loja',
                    ),
                    _buildServiceOption(context,
                      value: _editableConfig!.tableEnabled,
                      onChanged: (v) => _onConfigChanged(_editableConfig!.copyWith(tableEnabled: v ?? false)),
                      title: 'Consumo no local',
                      description: 'O cliente faz o pedido e consome no local (mesas)',
                    ),

                    const SizedBox(height: 32),

                    // SEÇÃO 2 - ÁREAS DE ENTREGA
                    // ✅ Lendo do estado local
                    if (_editableConfig!.deliveryEnabled) ...[
                      const Text('Áreas de Entrega', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                            child: _buildDeliveryScopeRadio(context,
                                value: 'neighborhood',
                                // ✅ Lendo do estado local
                                groupValue: _editableConfig!.deliveryScope,
                                // ✅ Atualizando o estado local
                                onChanged: (v) => _onConfigChanged(_editableConfig!.copyWith(deliveryScope: v)),
                                label: 'Por bairros')),
                        Expanded(
                            child: _buildDeliveryScopeRadio(context,
                                value: 'city',
                                groupValue: _editableConfig!.deliveryScope,
                                onChanged: (v) => _onConfigChanged(_editableConfig!.copyWith(deliveryScope: v)),
                                label: 'Por cidade'))
                      ]),
                      const SizedBox(height: 25),
                    ],

                    // SEÇÃO 3 - VALOR MÍNIMO
                    if (_editableConfig!.deliveryEnabled) ...[
                      const Text('Valor Mínimo para Pedidos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      AppTextField(
                        initialValue: _editableConfig!.deliveryMinOrder?.toString() ?? '',
                        title: 'Pedido mínimo (R\$)',
                        hint: 'Ex: 20.00',
                        keyboardType: TextInputType.number,
                        formatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],

                        onChanged: (v) => _onConfigChanged(_editableConfig!.copyWith(deliveryMinOrder: double.tryParse((v ?? '').replaceAll(',', '.')) ?? 0.0)),

                      ),
                      const SizedBox(height: 32),
                    ],

                    // SEÇÃO 4 - TEMPOS DE PREPARAÇÃO
                    const Text('Tempo de Preparação', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Defina os tempos estimados para cada modo', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),

                    if (_editableConfig!.deliveryEnabled)
                      _buildTimeRangeSelector(
                          title: 'Delivery',
                          minValue: _editableConfig!.deliveryEstimatedMin ?? 10,
                          maxValue: _editableConfig!.deliveryEstimatedMax ?? 30,
                          onMinChanged: (v) => _onConfigChanged(_editableConfig!.copyWith(deliveryEstimatedMin: v)),
                          onMaxChanged: (v) => _onConfigChanged(_editableConfig!.copyWith(deliveryEstimatedMax: v))),
                    if (_editableConfig!.pickupEnabled)
                      _buildTimeRangeSelector(
                          title: 'Retirada na loja',
                          minValue: _editableConfig!.pickupEstimatedMin ?? 5,
                          maxValue: _editableConfig!.pickupEstimatedMax ?? 15,
                          onMinChanged: (v) => _onConfigChanged(_editableConfig!.copyWith(pickupEstimatedMin: v)),
                          onMaxChanged: (v) => _onConfigChanged(_editableConfig!.copyWith(pickupEstimatedMax: v))),
                    if (_editableConfig!.tableEnabled) ...[
                      _buildTimeRangeSelector(
                          title: 'Mesas',
                          minValue: _editableConfig!.tableEstimatedMin ?? 5,
                          maxValue: _editableConfig!.tableEstimatedMax ?? 15,
                          onMinChanged: (v) => _onConfigChanged(_editableConfig!.copyWith(tableEstimatedMin: v)),
                          onMaxChanged: (v) => _onConfigChanged(_editableConfig!.copyWith(tableEstimatedMax: v))),
                      const SizedBox(height: 8),
                      AppTextField(
                        initialValue: _editableConfig!.tableInstructions ?? '',
                        title: 'Instruções para mesas',
                        hint: 'Ex: Escolha uma mesa disponível e aguarde atendimento',
                        onChanged: (v) => _onConfigChanged(_editableConfig!.copyWith(tableInstructions: v)),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _buildServiceOption(
      BuildContext context, {
        required bool value,
        required ValueChanged<bool?> onChanged,
        required String title,
        required String description,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryScopeRadio(
      BuildContext context, {
        required String value,
        required String? groupValue,
        required ValueChanged<String?> onChanged,
        required String label,
      }) {
    return RadioListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      title: Text(label),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }

  Widget _buildTimeRangeSelector({
    required String title,
    required int minValue,
    required int maxValue,
    required ValueChanged<int> onMinChanged,
    required ValueChanged<int> onMaxChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: AppCounterFormField(
                initialValue: minValue,
                minValue: 1,
                maxValue: 60,
                title: 'Mínimo (min)',
                onChanged: onMinChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppCounterFormField(
                initialValue: maxValue,
                minValue: 1,
                maxValue: 120,
                title: 'Máximo (min)',
                onChanged: onMaxChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

}