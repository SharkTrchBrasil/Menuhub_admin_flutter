// lib/pages/product_groups/widgets/create_complement_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/variant_option.dart';

import '../cubit/complement_form_cubit.dart';
import 'industrialized_flow.dart';
import 'prepared_form-view.dart';
import 'product_type_dropbox.dart';

class CreateComplementPanel extends StatelessWidget {
  // ✅ 1. ADICIONE UMA PROPRIEDADE PARA RECEBER OS DADOS INICIAIS
  final VariantOption? initialData;

  const CreateComplementPanel({super.key, this.initialData});


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ComplementFormCubit(initialData: initialData),
      child: BlocListener<ComplementFormCubit, ComplementFormState>(
        listener: (context, state) {
          if (state.createdOption != null) {
            Navigator.of(context).pop(state.createdOption);
          }
        },

        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.9,
            maxChildSize: 0.9,
            expand: false,
            builder: (_, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                // ✅ 1. Usamos um ListView como filho direto. Ele é mais simples e eficiente.
                child: ListView(
                  // ✅ 2. O segredo está aqui: passamos o controller do DraggableScrollableSheet.
                  controller: scrollController,
                  children: [
                    // --- Cabeçalho do Painel ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 26),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Criar novo complemento",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          )
                        ],
                      ),
                    ),



                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      child: _PanelBody(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Widget interno que constrói o corpo do painel (sem alterações)
class _PanelBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ComplementFormCubit>();
    final state = cubit.state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProductTypeDropdown(
          isPrepared: state.isPrepared,
          onChanged: (value) => cubit.toggleProductType(value),
        ),

        // --- Formulário Dinâmico ---
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: state.isPrepared
              ? PreparedFormView(key: const ValueKey('prepared'))
              : IndustrializedFlowView(key: const ValueKey('industrialized')),
        ),
      ],
    );
  }
}