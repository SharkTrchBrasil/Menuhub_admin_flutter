// Salve como: pages/edit_settings/tabs/operation_configuration_page.dart

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';

import 'package:totem_pro_admin/repositories/store_operation_config_repository.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import 'package:totem_pro_admin/widgets/fixed_header.dart';
import 'dart:developer';

import '../../../core/di.dart';
import '../../../widgets/app_counter_form_field.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_toasts.dart' as AppToasts;
import '../../models/store/store_operation_config.dart';

class OperationConfigurationPage extends StatefulWidget {
  final int storeId;

  const OperationConfigurationPage({super.key, required this.storeId});

  @override
  State<OperationConfigurationPage> createState() => _OperationConfigurationPageState();
}

class _OperationConfigurationPageState extends State<OperationConfigurationPage> {
  final StoreOperationConfigRepository storeRepository = getIt();
  final formKey = GlobalKey<FormState>();

  StoreOperationConfig? _editableConfig;
  int? _storeIdForSync;
  DateTime? _lastUpdateFromCubit;

  Future<void> _save() async {
    if (formKey.currentState?.validate() != true || _editableConfig == null) return;

    final l = AppToasts.showLoading();
    final result = await storeRepository.updateConfiguration(widget.storeId, _editableConfig!);
    l();

    result.fold(
          (error) => AppToasts.showError('Erro ao salvar configurações.'),
          (success) {
        AppToasts.showSuccess('Configurações de operação salvas!');
      },
    );
  }

  void _onConfigChanged(StoreOperationConfig newConfig) {
    setState(() {
      _editableConfig = newConfig;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definimos a variável `isMobile` uma vez aqui para usar em todo o build.
    final bool isMobile = ResponsiveBuilder.isMobile(context);

    return Scaffold(
      // O BottomNavigationBar já estava ótimo para mobile.
      bottomNavigationBar: isMobile ? Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), // Ajuste de padding
        child: DsButton(
          onPressed: _save,
          label: 'Salvar Alterações',
        ),
      ) : const SizedBox.shrink(),
      body: Form(
        key: formKey,
        child: _buildPageContent(isMobile: isMobile),
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

        return Padding(
          padding:  EdgeInsets.symmetric(horizontal: ResponsiveBuilder.isDesktop(context) ? 24: 14.0),
          child: SingleChildScrollView(

            child: Column(
              children: [
                FixedHeader(
                  title: 'Configurações de operação', // Título mais genérico
                  subtitle: 'Defina os modos de serviço, áreas e tempos da sua loja.',
                  actions: [
                    // Botão só aparece em desktop.

                      DsButton(
                        // ✅ CORREÇÃO DE TEXTO
                        label: 'Salvar configurações',
                        onPressed: _save,
                      )
                  ],
                ),
                const SizedBox(height: 30),
                // A estrutura Expanded + SingleChildScrollView está correta para garantir a rolagem.
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SEÇÃO 1 - MODOS DE SERVIÇO
                    _buildServiceOption(context,
                      value: _editableConfig!.deliveryEnabled,
                      onChanged: (v) => _onConfigChanged(_editableConfig!.copyWith(deliveryEnabled: v ?? false)),
                      title: 'Entrega (Delivery)',
                      description: 'O pedido chega até o cliente por um entregador.',
                    ),
                    _buildServiceOption(context,
                      value: _editableConfig!.pickupEnabled,
                      onChanged: (v) => _onConfigChanged(_editableConfig!.copyWith(pickupEnabled: v ?? false)),
                      title: 'Retirada na loja',
                      description: 'O cliente retira o pedido no balcão da loja.',
                    ),
                    _buildServiceOption(context,
                      value: _editableConfig!.tableEnabled,
                      onChanged: (v) => _onConfigChanged(_editableConfig!.copyWith(tableEnabled: v ?? false)),
                      title: 'Consumo no local',
                      description: 'O cliente faz o pedido e consome no local (mesas).',
                    ),

                    const SizedBox(height: 32),

                    // SEÇÃO 2 - ÁREAS DE ENTREGA
                    if (_editableConfig!.deliveryEnabled) ...[
                      const Text('Áreas de Entrega', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      // Em mobile, os Radios podem ficar em linha, pois o texto é curto.
                      Row(children: [
                        Expanded(
                            child: _buildDeliveryScopeRadio(context,
                                value: 'neighborhood',
                                groupValue: _editableConfig!.deliveryScope,
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
                      const Text('Valores para Delivery', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      // ✅ ALTERAÇÃO: Layout condicional para os campos de valor.
                      _buildResponsiveRowOrColumn(
                        isMobile: isMobile,
                        children: [
                          AppTextField(
                            initialValue: _editableConfig!.deliveryMinOrder?.toString() ?? '',
                            title: 'Pedido mínimo (R\$)',
                            hint: 'Ex: 20.00',
                            keyboardType: TextInputType.number,

                            formatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              CentavosInputFormatter(moeda: true),
                            ],
                            onChanged: (v) => _onConfigChanged(_editableConfig!.copyWith(deliveryMinOrder: double.tryParse((v ?? '').replaceAll(',', '.')) ?? 0.0)),
                          ),
                          AppTextField(
                            initialValue: _editableConfig!.freeDeliveryThreshold?.toString() ?? '',
                            title: 'Frete grátis acima de (R\$)',
                            hint: 'Ex: 50.00',
                            keyboardType: TextInputType.number,
                            formatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              CentavosInputFormatter(moeda: true),


                            ],
                            onChanged: (v) => _onConfigChanged(_editableConfig!.copyWith(freeDeliveryThreshold: double.tryParse((v ?? '').replaceAll(',', '.')) ?? 0.0)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],


                // SEÇÃO 4 - TEMPOS DE PREPARAÇÃO
                            // ✅ ALTERAÇÃO: Este bloco inteiro só será exibido se pelo menos um serviço estiver ativo.
                if (_editableConfig!.deliveryEnabled ||
                _editableConfig!.pickupEnabled ||
                _editableConfig!.tableEnabled) ...[


                    // SEÇÃO 4 - TEMPOS DE PREPARAÇÃO
                    const Text('Tempo de Preparação', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Defina os tempos estimados para cada modo de serviço.', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),

                    if (_editableConfig!.deliveryEnabled)
                      _buildTimeRangeSelector(
                          isMobile: isMobile, // Passa o flag
                          title: 'Delivery',
                          minValue: _editableConfig!.deliveryEstimatedMin ?? 10,
                          maxValue: _editableConfig!.deliveryEstimatedMax ?? 30,
                          onMinChanged: (v) => _onConfigChanged(_editableConfig!.copyWith(deliveryEstimatedMin: v)),
                          onMaxChanged: (v) => _onConfigChanged(_editableConfig!.copyWith(deliveryEstimatedMax: v))),
                    if (_editableConfig!.pickupEnabled)
                      _buildTimeRangeSelector(
                          isMobile: isMobile, // Passa o flag
                          title: 'Retirada na loja',
                          minValue: _editableConfig!.pickupEstimatedMin ?? 5,
                          maxValue: _editableConfig!.pickupEstimatedMax ?? 15,
                          onMinChanged: (v) => _onConfigChanged(_editableConfig!.copyWith(pickupEstimatedMin: v)),
                          onMaxChanged: (v) => _onConfigChanged(_editableConfig!.copyWith(pickupEstimatedMax: v))),
                    if (_editableConfig!.tableEnabled) ...[
                      _buildTimeRangeSelector(
                          isMobile: isMobile, // Passa o flag
                          title: 'Consumo no Local',
                          minValue: _editableConfig!.tableEstimatedMin ?? 5,
                          maxValue: _editableConfig!.tableEstimatedMax ?? 15,
                          onMinChanged: (v) => _onConfigChanged(_editableConfig!.copyWith(tableEstimatedMin: v)),
                          onMaxChanged: (v) => _onConfigChanged(_editableConfig!.copyWith(tableEstimatedMax: v))),
                      const SizedBox(height: 8),
                      AppTextField(
                        initialValue: _editableConfig!.tableInstructions ?? '',
                        title: 'Instruções para consumo no local',
                        hint: 'Ex: Escolha uma mesa e aguarde o atendimento.',
                        onChanged: (v) => _onConfigChanged(_editableConfig!.copyWith(tableInstructions: v)),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],

                                  ]
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ NOVO WIDGET HELPER: Cria uma Row em desktop ou uma Column em mobile.
  Widget _buildResponsiveRowOrColumn({
    required bool isMobile,
    required List<Widget> children,
    double spacing = 16.0,
  }) {
    if (isMobile) {
      // Em mobile, usa Column com um SizedBox entre os filhos.
      return Column(
        children: children.expand((widget) => [widget, SizedBox(height: spacing)]).toList()..removeLast(),
      );
    } else {
      // Em desktop, usa Row com Flexible para dividir o espaço.
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .map((w) => Expanded(child: w))
            .expand((widget) => [widget, SizedBox(width: spacing)])
            .toList()
          ..removeLast(),
      );
    }
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
          SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
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
    return RadioListTile<String>(
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      title: Text(label),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }

  // ✅ ALTERAÇÃO: Este widget agora é responsivo internamente.
  Widget _buildTimeRangeSelector({
    required bool isMobile,
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
        const SizedBox(height: 12),
        _buildResponsiveRowOrColumn(
          isMobile: isMobile,
          children: [
            AppCounterFormField(
              initialValue: minValue,
              minValue: 1,
              maxValue: 60,
              title: 'Mínimo (min)',
              onChanged: onMinChanged,
            ),
            AppCounterFormField(
              initialValue: maxValue,
              minValue: 1,
              maxValue: 120,
              title: 'Máximo (min)',
              onChanged: onMaxChanged,
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}