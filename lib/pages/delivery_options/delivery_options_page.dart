import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/delivery_options.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/fixed_header.dart';
import 'package:totem_pro_admin/widgets/mobileappbar.dart';

import '../../core/app_edit_controller.dart';
import '../../core/di.dart';
import '../../repositories/delivery_options_repository.dart';
import '../../repositories/store_repository.dart';
import '../../widgets/app_counter_form_field.dart';
import '../../widgets/app_page_status_builder.dart';
import '../../widgets/app_text_field.dart';
import '../base/BasePage.dart';

class DeliveryOptionsPage extends StatefulWidget {
  final int storeId;

  const DeliveryOptionsPage({super.key, required this.storeId});

  @override
  State<DeliveryOptionsPage> createState() => _DeliveryOptionsPageState();
}

class _DeliveryOptionsPageState extends State<DeliveryOptionsPage> {
  final DeliveryOptionRepository storeRepository = getIt();

  final formKey = GlobalKey<FormState>();

  DeliveryScope selected = DeliveryScope.neighborhood;

  late final AppEditController<void, DeliveryOptionsModel> controller =
      AppEditController<void, DeliveryOptionsModel>(
        id: widget.storeId,
        fetch: (id) => storeRepository.getStoreDeliveryConfig(id),
        save:
            (pixConfig) => storeRepository.updateStoreDeliveryConfig(
              widget.storeId,
              pixConfig,
            ),
        empty: () => DeliveryOptionsModel(),
      );

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: BasePage(
        mobileAppBar: AppBarCustom(title: 'Formas de entrega'),
        mobileBuilder: (context) {
          return AnimatedBuilder(
            animation: controller,
            builder: (_, __) {
              return AppPageStatusBuilder<DeliveryOptionsModel>(
                status: controller.status,
                successBuilder: (config) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // SEÇÃO 1 - MODO DE ENTREGA
                          const Text('Modo de Entrega'),
                          const SizedBox(height: 4),

                          const SizedBox(height: 16),
                          // ENTREGA
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: config.deliveryEnabled,
                                onChanged:
                                    (v) => controller.onChanged(
                                      config.copyWith(
                                        deliveryEnabled: v ?? false,
                                      ),
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('Entrega'),
                                    SizedBox(height: 2),
                                    Text(
                                      'O pedido chega até o cliente por um entregador',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // RETIRADA
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: config.pickupEnabled,
                                onChanged:
                                    (v) => controller.onChanged(
                                      config.copyWith(
                                        pickupEnabled: v ?? false,
                                      ),
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('Retirada na loja'),
                                    SizedBox(height: 2),
                                    Text(
                                      'O cliente retira o pedido no balcão da loja',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // CONSUMO NO LOCAL
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: config.tableEnabled,
                                onChanged:
                                    (v) => controller.onChanged(
                                      config.copyWith(tableEnabled: v ?? false),
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('Consumo no local'),
                                    SizedBox(height: 2),
                                    Text(
                                      'O cliente faz o pedido e consome no local (mesas)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // SEÇÃO 2 - ÁREAS E TAXAS DE ENTREGA
                          const Text('Áreas e Taxas de Entrega'),
                          const SizedBox(height: 4),

                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile(
                                  contentPadding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                  title: Text('Por bairros'),
                                  value: 'neighborhood',
                                  // valor único desta opção
                                  groupValue: config.deliveryScope,
                                  // valor atual selecionado
                                  onChanged:
                                      (v) => controller.onChanged(
                                        config.copyWith(deliveryScope: v),
                                      ),
                                ),
                              ),

                              Expanded(
                                child: RadioListTile(
                                  contentPadding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                  title: Text('Por cidade'),
                                  value: 'city',
                                  // valor único desta opção
                                  groupValue: config.deliveryScope,
                                  onChanged:
                                      (v) => controller.onChanged(
                                        config.copyWith(deliveryScope: v),
                                      ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          // SEÇÃO 3 - VALOR MÍNIMO PARA PEDIDOS
                          const Text('Valor Mínimo para Pedidos'),
                          const SizedBox(height: 4),

                          const SizedBox(height: 16),

                          AppTextField(
                            initialValue:
                                config.deliveryMinOrder?.toString() ?? '',
                            title: 'Pedido mínimo (R\$)',
                            hint: 'Ex: 20.00',
                            onChanged:
                                (v) => controller.onChanged(
                                  config.copyWith(
                                    deliveryMinOrder:
                                        double.tryParse(v ?? '') ?? 0.0,
                                  ),
                                ),
                          ),

                          const SizedBox(height: 32),

                          // SEÇÃO 4 - TEMPO DE ENTREGA
                          const Text('Tempo de Entrega'),
                          const SizedBox(height: 4),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              // ENTREGA
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Delivery',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AppCounterFormField(
                                            initialValue:
                                                config.deliveryEstimatedMin ?? 10,
                                            minValue: 1,
                                            maxValue: 60,
                                            title: 'Mínimo',
                                            onChanged:
                                                (v) => controller.onChanged(
                                                  config.copyWith(
                                                    deliveryEstimatedMin: v,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      //  const SizedBox(width: 30),
                                        Expanded(
                                          child: AppCounterFormField(
                                            initialValue:
                                                config.deliveryEstimatedMax ?? 30,
                                            minValue: 1,
                                            maxValue: 120,
                                            title: 'Máximo',
                                            onChanged:
                                                (v) => controller.onChanged(
                                                  config.copyWith(
                                                    deliveryEstimatedMax: v,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 25),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Retirada na loja',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AppCounterFormField(
                                            initialValue:
                                                config.pickupEstimatedMin ?? 5,
                                            minValue: 1,
                                            maxValue: 60,
                                            title: 'Mínimo',
                                            onChanged:
                                                (v) => controller.onChanged(
                                                  config.copyWith(
                                                    pickupEstimatedMin: v,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      //  const SizedBox(width: 30),
                                        Expanded(
                                          child: AppCounterFormField(
                                            initialValue:
                                                config.pickupEstimatedMax ?? 15,
                                            minValue: 1,
                                            maxValue: 120,
                                            title: 'Máximo',
                                            onChanged:
                                                (v) => controller.onChanged(
                                                  config.copyWith(
                                                    pickupEstimatedMax: v,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mesas',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppCounterFormField(
                                      initialValue: config.tableEstimatedMin ?? 5,
                                      minValue: 1,
                                      maxValue: 60,
                                      title: 'Mínimo',
                                      onChanged:
                                          (v) => controller.onChanged(
                                            config.copyWith(tableEstimatedMin: v),
                                          ),
                                    ),
                                  ),
                           //       const SizedBox(width: 30),
                                  Expanded(
                                    child: AppCounterFormField(
                                      initialValue:
                                          config.tableEstimatedMax ?? 15,
                                      minValue: 1,
                                      maxValue: 120,
                                      title: 'Máximo',
                                      onChanged:
                                          (v) => controller.onChanged(
                                            config.copyWith(tableEstimatedMax: v),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              AppTextField(
                                initialValue: config.tableInstructions ?? '',
                                title: 'Instruções para mesas',
                                hint:
                                    'Ex: Escolha uma mesa disponível e aguarde atendimento',
                                onChanged:
                                    (v) => controller.onChanged(
                                      config.copyWith(tableInstructions: v),
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },

        desktopBuilder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FixedHeader(
                title: 'Dados de entrega',

                actions: [
                  AppPrimaryButton(
                    label: 'Salvar',

                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        await controller.saveData();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (_, __) {
                    return AppPageStatusBuilder<DeliveryOptionsModel>(
                      status: controller.status,
                      successBuilder: (config) {
                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // SEÇÃO 1 - MODO DE ENTREGA
                                const Text('Modo de Entrega'),
                                const SizedBox(height: 4),
                                const Text(
                                  'Escolha as opções que melhor representam as modalidades de entrega/retirada da sa loja',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // ENTREGA
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      value: config.deliveryEnabled,
                                      onChanged:
                                          (v) => controller.onChanged(
                                            config.copyWith(
                                              deliveryEnabled: v ?? false,
                                            ),
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: const [
                                          Text('Entrega'),
                                          SizedBox(height: 2),
                                          Text(
                                            'O pedido chega até o cliente por um entregador',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // RETIRADA
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      value: config.pickupEnabled,
                                      onChanged:
                                          (v) => controller.onChanged(
                                            config.copyWith(
                                              pickupEnabled: v ?? false,
                                            ),
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: const [
                                          Text('Retirada na loja'),
                                          SizedBox(height: 2),
                                          Text(
                                            'O cliente retira o pedido no balcão da loja',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // CONSUMO NO LOCAL
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      value: config.tableEnabled,
                                      onChanged:
                                          (v) => controller.onChanged(
                                            config.copyWith(
                                              tableEnabled: v ?? false,
                                            ),
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: const [
                                          Text('Consumo no local'),
                                          SizedBox(height: 2),
                                          Text(
                                            'O cliente faz o pedido e consome no local (mesas)',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),

                                // SEÇÃO 2 - ÁREAS E TAXAS DE ENTREGA
                                const Text('Áreas e Taxas de Entrega'),
                                const SizedBox(height: 4),
                                const Text(
                                  'Configure os valores cobrados para entrega e os bairros atendidos',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: RadioListTile(
                                        contentPadding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                        title: Text('Por bairros'),
                                        value: 'neighborhood',
                                        // valor único desta opção
                                        groupValue: config.deliveryScope,
                                        // valor atual selecionado
                                        onChanged:
                                            (v) => controller.onChanged(
                                              config.copyWith(deliveryScope: v),
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: 28),
                                    Expanded(
                                      child: RadioListTile(
                                        contentPadding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                        title: Text('Por cidade'),
                                        value: 'city',
                                        // valor único desta opção
                                        groupValue: config.deliveryScope,
                                        onChanged:
                                            (v) => controller.onChanged(
                                              config.copyWith(deliveryScope: v),
                                            ),
                                      ),
                                    ),
                                    Spacer()


                                  ],
                                ),

                                const SizedBox(height: 32),

                                // SEÇÃO 3 - VALOR MÍNIMO PARA PEDIDOS
                                const Text('Valor Mínimo para Pedidos'),
                                const SizedBox(height: 4),
                                const Text(
                                  'Defina o valor mínimo que o cliente deve gastar para fazer um pedido',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                SizedBox(
                                  width: 200,
                                  child: AppTextField(
                                    initialValue:
                                        config.deliveryMinOrder?.toString() ??
                                        '',
                                    title: 'Pedido mínimo (R\$)',
                                    hint: 'Ex: 20.00',
                                    onChanged:
                                        (v) => controller.onChanged(
                                          config.copyWith(
                                            deliveryMinOrder:
                                                double.tryParse(v ?? '') ?? 0.0,
                                          ),
                                        ),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // SEÇÃO 4 - TEMPO DE ENTREGA
                                const Text('Tempo de Entrega'),
                                const SizedBox(height: 4),
                                const Text(
                                  'Informe o tempo mínimo e máximo estimado para entrega, retirada e mesas',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    // ENTREGA
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Entrega',
                                            style: TextStyle(),
                                          ),
                                          const SizedBox(height: 18),
                                          Row(
                                            children: [
                                              AppCounterFormField(
                                                initialValue:
                                                    config
                                                        .deliveryEstimatedMin ??
                                                    10,
                                                minValue: 1,
                                                maxValue: 60,
                                                title: 'Mínimo',
                                                onChanged:
                                                    (v) => controller.onChanged(
                                                      config.copyWith(
                                                        deliveryEstimatedMin: v,
                                                      ),
                                                    ),
                                              ),
                                              const SizedBox(width: 60),
                                              AppCounterFormField(
                                                initialValue:
                                                    config
                                                        .deliveryEstimatedMax ??
                                                    30,
                                                minValue: 1,
                                                maxValue: 120,
                                                title: 'Máximo',
                                                onChanged:
                                                    (v) => controller.onChanged(
                                                      config.copyWith(
                                                        deliveryEstimatedMax: v,
                                                      ),
                                                    ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'minutos',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // RETIRADA NA LOJA
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Retirada na loja',
                                            style: TextStyle(),
                                          ),
                                          const SizedBox(height: 18),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: AppCounterFormField(
                                                  initialValue:
                                                      config.pickupEstimatedMin ??
                                                      5,
                                                  minValue: 1,
                                                  maxValue: 60,
                                                  title: 'Mínimo',
                                                  onChanged:
                                                      (v) => controller.onChanged(
                                                        config.copyWith(
                                                          pickupEstimatedMin: v,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(width: 60),
                                              Expanded(
                                                child: AppCounterFormField(
                                                  initialValue:
                                                      config.pickupEstimatedMax ??
                                                      15,
                                                  minValue: 1,
                                                  maxValue: 120,
                                                  title: 'Máximo',
                                                  onChanged:
                                                      (v) => controller.onChanged(
                                                        config.copyWith(
                                                          pickupEstimatedMax: v,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'minutos',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 25),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Mesas', style: TextStyle()),
                                    const SizedBox(height: 18),
                                    Row(
                                      children: [
                                        AppCounterFormField(
                                          initialValue:
                                              config.tableEstimatedMin ?? 5,
                                          minValue: 1,
                                          maxValue: 60,
                                          title: 'Mínimo',
                                          onChanged:
                                              (v) => controller.onChanged(
                                                config.copyWith(
                                                  tableEstimatedMin: v,
                                                ),
                                              ),
                                        ),
                                        const SizedBox(width: 60),
                                        AppCounterFormField(
                                          initialValue:
                                              config.tableEstimatedMax ?? 15,
                                          minValue: 1,
                                          maxValue: 120,
                                          title: 'Máximo',
                                          onChanged:
                                              (v) => controller.onChanged(
                                                config.copyWith(
                                                  tableEstimatedMax: v,
                                                ),
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'minutos',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    SizedBox(
                                      width: 300,
                                      child: AppTextField(
                                        initialValue:
                                            config.tableInstructions ?? '',
                                        title: 'Instruções para mesas',
                                        hint:
                                            'Ex: Escolha uma mesa disponível e aguarde atendimento',
                                        onChanged:
                                            (v) => controller.onChanged(
                                              config.copyWith(
                                                tableInstructions: v,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },

        mobileBottomNavigationBar: AppPrimaryButton(
          label: 'Salvar',

          onPressed: () async {
            if (formKey.currentState!.validate()) {
              await controller.saveData();
            }
          },
        ),
      ),
    );
  }
}

enum DeliveryScope { neighborhood, city }
