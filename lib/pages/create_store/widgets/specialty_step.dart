import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/page_status.dart';
import '../../../models/segment.dart';
import '../cubit/store_setup_cubit.dart';
import '../cubit/store_setup-state.dart';

class SpecialtyStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const SpecialtyStep({required this.formKey, super.key});

  @override
  State<SpecialtyStep> createState() => _SpecialtyStepState();
}

class _SpecialtyStepState extends State<SpecialtyStep> {
  // O seu initState já chama o fetchSpecialties(), o que é perfeito para esta abordagem.
  @override
  void initState() {
    super.initState();
    context.read<CreateStoreCubit>().fetchSpecialties();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateStoreCubit, CreateStoreState>(
      builder: (context, state) {

        final cubit = context.read<CreateStoreCubit>();
        final status = state.specialtiesStatus;

        if (status is PageStatusLoading && state.specialtiesList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (status is PageStatusError && state.specialtiesList.isEmpty) {
          return Center(
            child: Text(
              status.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // ✅ PASSO 1: CORRIGIR A SELEÇÃO DO ITEM INICIAL
        // A lógica ficou muito mais simples. Apenas pegamos o objeto direto do estado.
        final selectedSegment = state.selectedSpecialty;
        return Form(
          key: widget.formKey,
          // ✅ MUDANÇA PRINCIPAL AQUI
          // Trocamos '.searchRequest' por '.search'
          child: CustomDropdown<Segment>.search(
            // `futureRequest` é removido e substituído por `items`.
            // Passamos a lista que já foi carregada pelo Cubit.
            items: state.specialtiesList,

            initialItem: selectedSegment,
            hintText: 'Selecione a especialidade',
            decoration: const CustomDropdownDecoration(


              closedBorder: Border.fromBorderSide(BorderSide(color: Colors.grey, width: 1)),
              closedBorderRadius: BorderRadius.all(Radius.circular(4)),
              expandedBorderRadius: BorderRadius.all(Radius.circular(4)),




              searchFieldDecoration: SearchFieldDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey),

                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
            ),

            validator: (item) => item == null ? 'Campo obrigatório' : null,
            onChanged: (segment) {
              if (segment != null) {

                cubit.updateBusinessField(specialty: segment);
              }
            },
          ),
        );
      },
    );
  }
}