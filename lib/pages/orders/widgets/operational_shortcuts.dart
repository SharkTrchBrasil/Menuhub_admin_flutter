// lib/pages/orders/widgets/operational_shortcuts.dart

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:totem_pro_admin/models/store.dart';
import 'package:totem_pro_admin/models/store_operation_config.dart';
import 'package:totem_pro_admin/repositories/store_operation_config_repository.dart';
import 'package:totem_pro_admin/widgets/app_counter_form_field.dart';
import 'package:totem_pro_admin/widgets/app_text_field.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart' as AppToasts;
import '../../../core/di.dart';

// ===================================================================
// WIDGET PRINCIPAL: A BARRA DE ATALHOS (Sem alterações)
// ===================================================================
class OperationalShortcutsBar extends StatelessWidget {
  final Store? store;
  final VoidCallback onEditDeliveryTime;
  final VoidCallback onEditMinOrder;

  const OperationalShortcutsBar({
    super.key,
    required this.store,
    required this.onEditDeliveryTime,
    required this.onEditMinOrder,
  });

  @override
  Widget build(BuildContext context) {
    final config = store?.relations.storeOperationConfig;

    final timeText = (config != null && config.deliveryEstimatedMin != null)
        ? '${config.deliveryEstimatedMin}-${config.deliveryEstimatedMax}min'
        : 'N/D';

    final minOrderText = (config != null && config.deliveryMinOrder != null && config.deliveryMinOrder! > 0)
        ? 'R\$ ${config.deliveryMinOrder!.toStringAsFixed(2).replaceAll('.', ',')}'
        : 'N/D';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildInfoChip(
              label: 'Tempo de Entrega',
              value: timeText,
              icon: Icons.timer_outlined,
              onTap: onEditDeliveryTime,
            ),
            const SizedBox(width: 8),
            _buildInfoChip(
              label: 'Pedido Mínimo',
              value: minOrderText,
              icon: Icons.monetization_on_outlined,
              onTap: onEditMinOrder,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Row(
        children: [
          Text(label),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      onPressed: onTap,
      backgroundColor: Colors.white,
      shape: StadiumBorder(side: BorderSide(color: Colors.grey.shade300)),
    );
  }
}

// ===================================================================
// BOTTOMSHEET 1: EDITAR TEMPO DE ENTREGA (Atualizado)
// ===================================================================
class EditDeliveryTimeBottomSheet extends StatefulWidget {
  final int storeId;
  final StoreOperationConfig initialConfig;

  const EditDeliveryTimeBottomSheet({
    super.key,
    required this.storeId,
    required this.initialConfig,
  });

  @override
  State<EditDeliveryTimeBottomSheet> createState() => _EditDeliveryTimeBottomSheetState();
}

class _EditDeliveryTimeBottomSheetState extends State<EditDeliveryTimeBottomSheet> {
  final StoreOperationConfigRepository _repository = getIt();
  late int _minTime;
  late int _maxTime;

  @override
  void initState() {
    super.initState();
    _minTime = widget.initialConfig.deliveryEstimatedMin ?? 10;
    _maxTime = widget.initialConfig.deliveryEstimatedMax ?? 30;
  }

  Future<void> _save() async {
    if (_minTime > _maxTime) {
      AppToasts.showError('O tempo mínimo não pode ser maior que o máximo.');
      return;
    }

    final updatedConfig = widget.initialConfig.copyWith(
      deliveryEstimatedMin: _minTime,
      deliveryEstimatedMax: _maxTime,
    );

    final l = AppToasts.showLoading();
    final result = await _repository.updateConfiguration(widget.storeId, updatedConfig);
    l();

    if (!mounted) return;

    result.fold(
          (error) => AppToasts.showError('Erro ao salvar as alterações.'),
          (success) {
        AppToasts.showSuccess('Tempo de entrega atualizado!');
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B00).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.access_time_rounded,
                    color: Color(0xFFFF6B00),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tempo de Entrega',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Defina o tempo estimado para entrega',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Content
            Row(
              children: [
                Expanded(
                  child: _buildTimeField(
                    title: 'Tempo Mínimo',
                    subtitle: 'minutos',
                    value: _minTime,
                    onChanged: (val) => setState(() => _minTime = val),
                    min: 1,
                    max: 60,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeField(
                    title: 'Tempo Máximo',
                    subtitle: 'minutos',
                    value: _maxTime,
                    onChanged: (val) => setState(() => _maxTime = val),
                    min: 1,
                    max: 120,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_minTime > _maxTime)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '⚠️ O tempo mínimo não pode ser maior que o máximo',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 32),

            // Footer
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DsButton(
                    label: 'Salvar Alterações',
                    onPressed: _save,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField({
    required String title,
    required String subtitle,
    required int value,
    required Function(int) onChanged,
    required int min,
    required int max,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 20),
                onPressed: value > min ? () => onChanged(value - 1) : null,
                style: IconButton.styleFrom(
                  foregroundColor: value > min ? const Color(0xFFFF6B00) : Colors.grey.shade400,
                ),
              ),
              Expanded(
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: value < max ? () => onChanged(value + 1) : null,
                style: IconButton.styleFrom(
                  foregroundColor: value < max ? const Color(0xFFFF6B00) : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ===================================================================
// BOTTOMSHEET 2: EDITAR PEDIDO MÍNIMO (Atualizado)
// ===================================================================
class EditMinOrderBottomSheet extends StatefulWidget {
  final int storeId;
  final StoreOperationConfig initialConfig;

  const EditMinOrderBottomSheet({
    super.key,
    required this.storeId,
    required this.initialConfig,
  });

  @override
  State<EditMinOrderBottomSheet> createState() => _EditMinOrderBottomSheetState();
}

class _EditMinOrderBottomSheetState extends State<EditMinOrderBottomSheet> {
  final StoreOperationConfigRepository _repository = getIt();
  double _minOrder = 0.0;

  @override
  void initState() {
    super.initState();
    _minOrder = widget.initialConfig.deliveryMinOrder ?? 0.0;
  }

  Future<void> _save() async {
    final updatedConfig = widget.initialConfig.copyWith(
      deliveryMinOrder: _minOrder,
    );

    final l = AppToasts.showLoading();
    final result = await _repository.updateConfiguration(widget.storeId, updatedConfig);
    l();

    if (!mounted) return;

    result.fold(
          (error) => AppToasts.showError('Erro ao salvar o pedido mínimo.'),
          (success) {
        AppToasts.showSuccess('Pedido mínimo atualizado!');
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B00).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    color: Color(0xFFFF6B00),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pedido Mínimo',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Defina o valor mínimo para delivery',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Valor mínimo para entrega',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    initialValue: UtilBrasilFields.obterReal(_minOrder, moeda: false),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      prefixText: 'R\$ ',
                      prefixStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CentavosInputFormatter(moeda: true),
                    ],
                    onChanged: (value) {
                      // 1. Limpa a string: remove 'R$', espaços, e pontos de milhar.
                      String cleanString = value.replaceAll('R\$', '').trim();

                      // 2. Substitui a vírgula decimal por um ponto, que é o formato que o Dart entende.
                      cleanString = cleanString.replaceAll('.', '').replaceAll(',', '.');

                      // 3. Converte a string limpa para double. Se a conversão falhar, usa 0.0.
                      setState(() {
                        _minOrder = double.tryParse(cleanString) ?? 0.0;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Digite o valor em reais',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Footer
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DsButton(
                    label: 'Salvar Alterações',
                    onPressed: _save,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}