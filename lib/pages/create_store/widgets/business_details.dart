import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/page_status.dart'; // Importe seu PageStatus
import '../../../widgets/app_text_field.dart';
import '../cubit/store_setup_cubit.dart';
import '../cubit/store_setup-state.dart';

// 1. Transforme em um StatefulWidget
class BusinessDetailsStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const BusinessDetailsStep({required this.formKey, super.key});

  @override
  State<BusinessDetailsStep> createState() => _BusinessDetailsStepState();
}

class _BusinessDetailsStepState extends State<BusinessDetailsStep> {
  @override
  void initState() {
    super.initState();
    // 2. Chama o método para buscar as especialidades assim que a tela é construída
    context.read<StoreSetupCubit>().fetchSpecialties();
  }

  @override
  Widget build(BuildContext context) {
    // 3. Usa o BlocBuilder para reconstruir a UI com base no estado
    return BlocBuilder<StoreSetupCubit, StoreSetupState>(
      builder: (context, state) {
        final cubit = context.read<StoreSetupCubit>();

        return Form(
          key: widget.formKey,
          child: ListView(
            children: [
              AppTextField(
                title: 'CNPJ',
                hint: '00.000.000/0000-00',
                initialValue: state.cnpj, // Garante que o valor seja mantido
                onChanged: (v) => cubit.updateBusinessField(cnpj: v),
                validator: (v) {
                  final digits = v?.replaceAll(RegExp(r'\D'), '') ?? '';
                  if (digits.isEmpty) return 'Obrigatório';
                  if (!CNPJValidator.isValid(digits)) return 'CNPJ inválido';
                  return null;
                },
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CnpjInputFormatter(),
                ],
              ),
              const SizedBox(height: 24),

              // 4. Renderização condicional para o dropdown
           //   _buildSpecialtyField(context, state),
            ],
          ),
        );
      },
    );
  }


}