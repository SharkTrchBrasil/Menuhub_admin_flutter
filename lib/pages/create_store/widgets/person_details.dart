import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brasil_fields/brasil_fields.dart';

import '../../../widgets/app_text_field.dart';
import '../cubit/store_setup-state.dart';
import '../cubit/store_setup_cubit.dart';

class PersonDetailsStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  const PersonDetailsStep({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    // Para ler o estado e reconstruir a tela quando ele mudar
    final state = context.watch<CreateStoreCubit>().state;
    // Para chamar métodos do cubit sem reconstruir a tela
    final cubit = context.read<CreateStoreCubit>();



    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
        
              AppTextField(
                title: 'CPF',
                keyboardType: TextInputType.number,
        
                initialValue: state.cpf, // Adicionado para manter o estado
                hint: '000.000.000-00',
                onChanged: (v) => cubit.updateResponsibleField(cpf: v),
                validator: (v) {
                  final digits = v?.replaceAll(RegExp(r'\D'), '') ?? '';
                  if (digits.isEmpty) return 'Obrigatório';
                  if (!CPFValidator.isValid(digits)) return 'CPF inválido';
                  return null;
                },
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CpfInputFormatter(),
                ],
              ),
              const SizedBox(height: 16),
        
            AppTextField(
              title: 'Nome Completo',
              // ✅ AQUI ESTÁ A MUDANÇA FINAL
              // O campo agora lê o valor inicial diretamente do estado do Cubit.
              initialValue: state.responsibleName,
              onChanged: (v) => cubit.updateResponsibleField(name: v),
              validator: (v) => (v?.isEmpty ?? true) ? 'Obrigatório' : null,
              hint: 'Nome como aparece no documento',
            ),
            const SizedBox(height: 16),
            AppTextField(
              keyboardType: TextInputType.number,
              title: 'Data de nascimento',
              initialValue: state.responsibleBirth, // Adicionado para manter o estado
              hint: 'DD/MM/AAAA',
              onChanged: (v) => cubit.updateResponsibleField(birth: v),
              validator: (v) => (v?.isEmpty ?? true) ? 'Obrigatório' : null,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                DataInputFormatter(),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String? validMobilePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefone obrigatório';
    }

    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length != 11 || !digitsOnly.startsWith('1') && digitsOnly[2] != '9') {
      return 'Telefone inválido';
    }

    return null;
  }
}