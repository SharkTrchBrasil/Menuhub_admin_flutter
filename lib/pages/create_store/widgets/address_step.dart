// Em lib/pages/store_setup/store_setup_page.dart

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/models/page_status.dart';
import 'package:flutter/material.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';

import '../../../widgets/app_text_field.dart';
import '../cubit/store_setup-state.dart';
import '../cubit/store_setup_cubit.dart';

class AddressStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  const AddressStep({required this.formKey});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreSetupCubit, StoreSetupState>(
      builder: (context, state) {
        final cubit = context.read<StoreSetupCubit>();
        final status = state.zipCodeStatus;

        // Verifica se já fez alguma busca (sucesso ou erro)
        final hasSearched = status is PageStatusSuccess || status is PageStatusError;

        return Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // --- CAMPO DE CEP ---
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
                        validator: (v) => (v == null || v.length < 10) ? 'CEP inválido' : null,
                        onChanged: (c) {
                          cubit.updateField(cep: c);

                          // Busca o endereço quando o CEP estiver completo
                          if (c != null && c.length == 10) {
                            cubit.searchZipCode(c);
                          }
                        },
                      ),
                    ),

                    // BOTÃO DE RELOAD QUANDO HOUVER ERRO E CEP COMPLETO
                    if (status is PageStatusError && state.cep.length == 10)
                      Padding(
                        padding: const EdgeInsets.only(top: 32.0, left: 8),
                        child: IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                          onPressed: () {
                            cubit.searchZipCode(state.cep);
                          },
                          tooltip: 'Tentar buscar novamente',
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // --- FEEDBACK DA BUSCA ---
                if (status is PageStatusLoading)
                  _buildLoadingFeedback()
                else if (status is PageStatusError)
                  _buildErrorFeedback(status, state.cep, cubit)
                else if (status is PageStatusSuccess)
                    _buildSuccessFeedback(),

                const SizedBox(height: 8),

                // --- CAMPOS DO ENDEREÇO (SÓ APARECEM APÓS BUSCA) ---
                if (hasSearched) _buildAddressFields(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingFeedback() {
    return Column(
      children: [
        LinearProgressIndicator(),
      ],
    );
  }

  Widget _buildErrorFeedback(PageStatusError status, String cep, StoreSetupCubit cubit) {
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
            icon: Icon(
              Icons.refresh,
              color: Colors.orange[800],
              size: 20,
            ),
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

  Widget _buildAddressFields(BuildContext context, StoreSetupState state) {
    final cubit = context.read<StoreSetupCubit>();

    return Column(
      children: [
        const SizedBox(height: 16),
        AppTextField(
          title: 'Rua / Avenida',
          initialValue: state.street,
          validator: (v) => (v?.isEmpty ?? true) ? 'Obrigatório' : null,
          onChanged: (v) => cubit.updateField(street: v),
          hint: 'Digite o nome da rua',
        ),
        const SizedBox(height: 16),

        AppTextField(
          title: 'Bairro',
          initialValue: state.neighborhood,
          validator: (v) => (v?.isEmpty ?? true) ? 'Obrigatório' : null,
          onChanged: (v) => cubit.updateField(neighborhood: v),
          hint: 'Digite o bairro',
        ),
        const SizedBox(height: 16),

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

        ResponsiveBuilder.isDesktop(context) ?
        Row(
          children: [
            Expanded(
              child: AppTextField(
                title: 'Cidade',
                initialValue: state.city,
                validator: (v) => (v?.isEmpty ?? true) ? 'Obrigatório' : null,
                onChanged: (v) => cubit.updateField(city: v),
                hint: 'Nome da cidade',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppTextField(
                title: 'Estado',
                initialValue: state.uf,
                validator: (v) => (v?.isEmpty ?? true) ? 'Obrigatório' : null,
                onChanged: (v) => cubit.updateField(uf: v),
                hint: 'UF',
              ),
            ),
          ],
        ) : Column(
          children: [
            AppTextField(
              title: 'Cidade',
              initialValue: state.city,
              validator: (v) => (v?.isEmpty ?? true) ? 'Obrigatório' : null,
              onChanged: (v) => cubit.updateField(city: v),
              hint: 'Nome da cidade',
            ),
            const SizedBox(height: 16),
            AppTextField(
              title: 'Estado',
              initialValue: state.uf,
              validator: (v) => (v?.isEmpty ?? true) ? 'Obrigatório' : null,
              onChanged: (v) => cubit.updateField(uf: v),
              hint: 'UF',
            ),
          ],
        ),
      ],
    );
  }
}