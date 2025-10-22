// lib/pages/create_store/widgets/address_step.dart (VERSÃO COMPLETA)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/responsive_builder.dart';
import '../../../core/utils/brazilian_states.dart';
import '../../../models/page_status.dart';
import '../../../widgets/app_text_field.dart';
import '../cubit/store_setup-state.dart';
import '../cubit/store_setup_cubit.dart';
import 'dart:ui' as ui; // ✅ ADICIONAR ESTE IMPORT

class AddressStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const AddressStep({required this.formKey});

  @override
  State<AddressStep> createState() => _AddressStepState();
}

class _AddressStepState extends State<AddressStep> {
  MapController? _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateStoreCubit, CreateStoreState>(
      builder: (context, state) {
        final cubit = context.read<CreateStoreCubit>();
        final status = state.zipCodeStatus;

        return Form(
          key: widget.formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // ═══════════════════════════════════════════════════════════
                // CAMPO CEP (código existente)
                // ═══════════════════════════════════════════════════════════
                AppTextField(
                  title: 'CEP',
                  hint: 'Digite o CEP para buscar o endereço',
                  initialValue: state.cep,
                  onChanged: (c) {
                    cubit.updateField(cep: c);
                    if (c != null && c.length == 10) {
                      cubit.searchZipCode(c);
                    }
                  },
                ),

                const SizedBox(height: 16),

                // Feedback da busca (código existente)
                if (status is PageStatusLoading) _buildLoadingFeedback(),
                if (status is PageStatusError) _buildErrorFeedback(status, state.cep, cubit),
                if (status is PageStatusSuccess) _buildSuccessFeedback(),

                const SizedBox(height: 16),

                // ═══════════════════════════════════════════════════════════
                // ✅ MAPA + SELETOR DE RAIO (NOVO)
                // ═══════════════════════════════════════════════════════════
                if (state.latitude != null && state.longitude != null)
                  _buildMapWithRadiusSelector(state, cubit),

                const SizedBox(height: 16),

                // Campos de endereço (código existente)
                if (status is PageStatusSuccess || status is PageStatusError)
                  _buildAddressFields(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ NOVO WIDGET: Mapa + Seletor de Raio Profissional
  Widget _buildMapWithRadiusSelector(
      CreateStoreState state,
      CreateStoreCubit cubit,
      ) {
    final location = LatLng(state.latitude!, state.longitude!);
    final radiusMeters = state.deliveryRadius * 1000; // Converte km para metros

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ═══════════════════════════════════════════════════════════
        // HEADER COM ÍCONE E TÍTULO
        // ═══════════════════════════════════════════════════════════
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delivery_dining,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Área de Entrega',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Ajuste o raio de entrega da sua loja',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ═══════════════════════════════════════════════════════════
        // MAPA INTERATIVO
        // ═══════════════════════════════════════════════════════════
        Container(
          height: 350,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                // Mapa
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: location,
                    initialZoom: _calculateZoomForRadius(state.deliveryRadius),
                    minZoom: 10.0,
                    maxZoom: 18.0,
                    onTap: (tapPosition, point) {
                      cubit.updateField(
                        latitude: point.latitude,
                        longitude: point.longitude,
                      );
                    },
                  ),
                  children: [
                    // Camada do mapa
                    TileLayer(
                      urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.menuhub.admin',
                    ),

                    // Círculo de raio de entrega
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: location,
                          radius: radiusMeters,
                          useRadiusInMeter: true,
                          color: Theme.of(context)
                              .primaryColor
                              .withOpacity(0.15),
                          borderColor: Theme.of(context).primaryColor,
                          borderStrokeWidth: 3,
                        ),
                      ],
                    ),

                    // Marcador da loja
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: location,
                          width: 80,
                          height: 80,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.store,
                                  color: Theme.of(context).primaryColor,
                                  size: 28,
                                ),
                              ),
                              // Pin pointer
                              CustomPaint(
                                size: const Size(20, 12),
                                painter: _PinPointerPainter(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Badge com informação de raio
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.adjust,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${state.deliveryRadius.toStringAsFixed(1)} km',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ═══════════════════════════════════════════════════════════
        // SLIDER PROFISSIONAL PARA RAIO
        // ═══════════════════════════════════════════════════════════
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Raio de Entrega',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${state.deliveryRadius.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Slider customizado
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Theme.of(context).primaryColor,
                  inactiveTrackColor: Colors.grey.shade300,
                  thumbColor: Theme.of(context).primaryColor,
                  overlayColor:
                  Theme.of(context).primaryColor.withOpacity(0.2),
                  thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 14),
                  overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 24),
                  trackHeight: 6,
                ),
                child: Slider(
                  value: state.deliveryRadius,
                  min: 1.0,
                  max: 50.0,
                  divisions: 49,
                  label: '${state.deliveryRadius.toStringAsFixed(1)} km',
                  onChanged: (value) {
                    cubit.updateField(deliveryRadius: value);

                    // Auto-zoom do mapa baseado no raio
                    final newZoom = _calculateZoomForRadius(value);
                    _mapController?.move(location, newZoom);
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Marcadores de distância
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDistanceMarker('1 km', '~10 min'),
                  _buildDistanceMarker('10 km', '~30 min'),
                  _buildDistanceMarker('25 km', '~1h'),
                  _buildDistanceMarker('50 km', '~2h'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Informação auxiliar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Você pode ajustar o raio de entrega a qualquer momento nas configurações',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Coordenadas (para debug/referência)
        Text(
          'Coordenadas: ${state.latitude!.toStringAsFixed(6)}, ${state.longitude!.toStringAsFixed(6)}',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  // Helper: Marcador de distância
  Widget _buildDistanceMarker(String distance, String time) {
    return Column(
      children: [
        Text(
          distance,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  // Helper: Calcula zoom ideal baseado no raio
  double _calculateZoomForRadius(double radiusKm) {
    if (radiusKm <= 5) return 14.0;
    if (radiusKm <= 10) return 13.0;
    if (radiusKm <= 20) return 12.0;
    if (radiusKm <= 30) return 11.5;
    return 11.0;
  }

  Widget _buildLoadingFeedback() {
    return const Column(
      children: [
        LinearProgressIndicator(),
      ],
    );
  }

  Widget _buildErrorFeedback(
      PageStatusError status,
      String cep,
      CreateStoreCubit cubit,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange[800]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CEP não encontrado',
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Preencha os dados manualmente abaixo',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.orange[800], size: 20),
            onPressed: () => cubit.searchZipCode(cep),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Tentar novamente',
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessFeedback() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[800]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Endereço encontrado! Confirme os dados abaixo.',
              style: TextStyle(
                color: Colors.green[800],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressFields(BuildContext context, CreateStoreState state) {
    final cubit = context.read<CreateStoreCubit>();

    return Column(
      children: [
        const SizedBox(height: 16),

        // ═══════════════════════════════════════════════════════════
        // RUA
        // ═══════════════════════════════════════════════════════════

        AppTextField(
          title: 'Rua / Avenida',
          initialValue: state.street,
          validator: (v) => (v?.isEmpty ?? true) ? 'Obrigatório' : null,
          onChanged: (v) => cubit.updateField(street: v),
          hint: 'Digite o nome da rua',
        ),
        const SizedBox(height: 16),

        // ═══════════════════════════════════════════════════════════
        // BAIRRO
        // ═══════════════════════════════════════════════════════════

        AppTextField(
          title: 'Bairro',
          initialValue: state.neighborhood,
          validator: (v) => (v?.isEmpty ?? true) ? 'Obrigatório' : null,
          onChanged: (v) => cubit.updateField(neighborhood: v),
          hint: 'Digite o bairro',
        ),
        const SizedBox(height: 16),

        // ═══════════════════════════════════════════════════════════
        // NÚMERO E COMPLEMENTO
        // ═══════════════════════════════════════════════════════════

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                title: 'Número',
                initialValue: state.number,
                keyboardType: TextInputType.number,
                validator: (v) => (v?.isEmpty ?? true) ? 'Obrigatório' : null,
                onChanged: (v) => cubit.updateField(number: v),
                hint: 'Nº',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppTextField(
                title: 'Complemento (Opcional)',
                initialValue: state.complement,
                onChanged: (v) => cubit.updateField(complement: v),
                hint: 'Apto, Bloco, etc.',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ═══════════════════════════════════════════════════════════
        // CIDADE E ESTADO (DROPDOWN)
        // ═══════════════════════════════════════════════════════════

        ResponsiveBuilder.isDesktop(context)
            ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CIDADE
            Expanded(
              child: AppTextField(
                title: 'Cidade',
                initialValue: state.city,
                validator: (v) =>
                (v?.isEmpty ?? true) ? 'Obrigatório' : null,
                onChanged: (v) => cubit.updateField(city: v),
                hint: 'Nome da cidade',
              ),
            ),
            const SizedBox(width: 16),

            // ✅ ESTADO (DROPDOWN)
            Expanded(
              child: _buildStateDropdown(context, state, cubit),
            ),
          ],
        )
            : Column(
          children: [
            // CIDADE
            AppTextField(
              title: 'Cidade',
              initialValue: state.city,
              validator: (v) =>
              (v?.isEmpty ?? true) ? 'Obrigatório' : null,
              onChanged: (v) => cubit.updateField(city: v),
              hint: 'Nome da cidade',
            ),
            const SizedBox(height: 16),

            // ✅ ESTADO (DROPDOWN)
            _buildStateDropdown(context, state, cubit),
          ],
        ),
      ],
    );
  }

  /// ✅ WIDGET DO DROPDOWN DE ESTADOS
  Widget _buildStateDropdown(
      BuildContext context,
      CreateStoreState state,
      CreateStoreCubit cubit,
      ) {
    // ✅ Normaliza o valor atual (pode vir como nome ou sigla)
    final normalizedState = BrazilianStates.normalizeState(state.uf);

    // ✅ Lista de estados (Sigla - Nome)
    final stateOptions = BrazilianStates.getAllAbbreviations()
        .map((abbr) {
      final name = BrazilianStates.getAbbrToNameMap()[abbr]!;
      return MapEntry(abbr, '$abbr - $name');
    })
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          'Estado (UF)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),

        // Dropdown
        DropdownButtonFormField<String>(
          value: normalizedState,
          decoration: InputDecoration(
            hintText: 'Selecione o estado',
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          icon: const Icon(Icons.arrow_drop_down),
          validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
          items: stateOptions
              .map((entry) => DropdownMenuItem<String>(
            value: entry.key,
            child: Text(
              entry.value,
              style: const TextStyle(fontSize: 14),
            ),
          ))
              .toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              cubit.updateField(uf: newValue);
            }
          },
          isExpanded: true,
          dropdownColor: Colors.white,
          menuMaxHeight: 300,
        ),
      ],
    );
  }

}

// ✅ PAINTER CORRIGIDO
class _PinPointerPainter extends CustomPainter {
  final Color color;

  _PinPointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // ✅ USAR ui.Path em vez de Path
    final path = ui.Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


