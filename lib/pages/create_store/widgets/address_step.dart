// Em lib/pages/store_setup/store_setup_page.dart

// Imports que você vai precisar no topo do arquivo
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    // Usamos o BlocBuilder para reconstruir a tela quando o estado do cubit mudar
    return BlocBuilder<StoreSetupCubit, StoreSetupState>(
      builder: (context, state) {
        final cubit = context.read<StoreSetupCubit>();
        final status = state.zipCodeStatus;

        return Form(
          key: formKey,
          child: ListView(
            children: [

              const SizedBox(height: 24),

              // --- CAMPO DE CEP ---
              AppTextField(
                title: 'CEP',
                hint: 'Digite o CEP para buscar o endereço',
                initialValue: state.cep,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CepInputFormatter(),
                ],
                validator: (v) => (v == null || v.length < 10) ? 'CEP inválido' : null,
                onChanged: (c) {
                  // ✅ CORREÇÃO: Atualiza o estado imediatamente com o valor digitado.
                  cubit.updateField(cep: c);

                  // Mantém a lógica de buscar o endereço quando o CEP estiver completo.
                  if (c != null && c.length == 10) {
                    cubit.searchZipCode(c);
                  }
                },
              ),
              const SizedBox(height: 24),

              // --- CONTEÚDO CONDICIONAL BASEADO NA BUSCA ---
              if (status is PageStatusLoading)
                const Center(child: CircularProgressIndicator())
              else if (status is PageStatusError)
                Center(child: Text(status.message, style: const TextStyle(color: Colors.red)))
              else if (status is PageStatusSuccess)
                  Column(
                    children: [
                      AppTextField(
                        title: 'Rua / Avenida',
                        initialValue: state.street,
                        validator: (v) => (v?.isEmpty ?? true) ? 'Obrigatório' : null,
                        onChanged: (v) => cubit.updateField(street: v), hint: '',
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        title: 'Bairro',
                        initialValue: state.neighborhood,
                        validator: (v) => (v?.isEmpty ?? true) ? 'Obrigatório' : null,
                        onChanged: (v) => cubit.updateField(neighborhood: v), hint: '',
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppTextField(
                              initialValue: state.number,

                              title: 'Número',

                              validator: (v) => (v?.isEmpty ?? true) ? 'Obrigatório' : null,
                              onChanged: (v) => cubit.updateField(number: v), hint: '',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              initialValue: state.complement,
                              title: 'Complemento (Opcional)',
                              onChanged: (v) => cubit.updateField(complement: v), hint: '',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              title: 'Cidade*',
                              initialValue: state.city,
                              enabled: false, hint: '', // Campo desabilitado
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(

                            child: AppTextField(
                              title: 'Estado*',
                              initialValue: state.uf,
                              enabled: false, hint: '', // Campo desabilitado
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
            ],
          ),
        );
      },
    );
  }
}