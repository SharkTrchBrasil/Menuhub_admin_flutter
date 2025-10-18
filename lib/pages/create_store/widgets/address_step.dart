// lib/pages/store_setup/address_step.dart

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/core/utils/brazilian_states.dart'; // ✅ IMPORTAR
import 'package:totem_pro_admin/models/page_status.dart';
import 'package:flutter/material.dart';

import '../../../widgets/app_text_field.dart';
import '../cubit/store_setup-state.dart';
import '../cubit/store_setup_cubit.dart';

class AddressStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  const AddressStep({required this.formKey});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateStoreCubit, CreateStoreState>(
      builder: (context, state) {
        final cubit = context.read<CreateStoreCubit>();
        final status = state.zipCodeStatus;

        final hasSearched = status is PageStatusSuccess || status is PageStatusError;

        return Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // ═══════════════════════════════════════════════════════════
                // CAMPO DE CEP
                // ═══════════════════════════════════════════════════════════

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        title: 'CEP',
                        hint: 'Digite o CEP para buscar o endereço',
                        initialValue: state.cep,
                        keyboardType: TextInputType.number,
                        formatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CepInputFormatter(),
                        ],
                        validator: (v) =>
                        (v == null || v.length < 10) ? 'CEP inválido' : null,
                        onChanged: (c) {
                          cubit.updateField(cep: c);

                          if (c != null && c.length == 10) {
                            cubit.searchZipCode(c);
                          }
                        },
                      ),
                    ),

                    if (status is PageStatusError && state.cep.length == 10)
                      Padding(
                        padding: const EdgeInsets.only(top: 32.0, left: 8),
                        child: IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                          onPressed: () => cubit.searchZipCode(state.cep),
                          tooltip: 'Tentar buscar novamente',
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // ═══════════════════════════════════════════════════════════
                // FEEDBACK DA BUSCA
                // ═══════════════════════════════════════════════════════════

                if (status is PageStatusLoading)
                  _buildLoadingFeedback()
                else if (status is PageStatusError)
                  _buildErrorFeedback(status, state.cep, cubit)
                else if (status is PageStatusSuccess)
                    _buildSuccessFeedback(),

                const SizedBox(height: 8),

                // ═══════════════════════════════════════════════════════════
                // CAMPOS DO ENDEREÇO
                // ═══════════════════════════════════════════════════════════

                if (hasSearched) _buildAddressFields(context, state),
              ],
            ),
          ),
        );
      },
    );
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