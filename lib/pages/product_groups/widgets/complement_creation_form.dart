import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/catalog_product.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/models/variant_option.dart';
import 'package:totem_pro_admin/pages/product_groups/widgets/prepared_form-view.dart';
import 'package:totem_pro_admin/widgets/app_image_form_field.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';

// Importe o novo Cubit
import '../cubit/complement_form_cubit.dart';
import 'industrialized_flow.dart';


typedef OnOptionCreated = void Function(VariantOption option);

class ComplementCreationForm extends StatelessWidget {
  final VoidCallback onCancel;
  final OnOptionCreated onOptionCreated;

  const ComplementCreationForm({
    super.key,
    required this.onCancel,
    required this.onOptionCreated,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Fornecemos uma instância do Cubit para este widget e seus filhos
    return BlocProvider(
      create: (_) => ComplementFormCubit(),
      // 2. Ouve mudanças no estado para executar ações (como chamar o callback)
      child: BlocListener<ComplementFormCubit, ComplementFormState>(
        listener: (context, state) {
          if (state.createdOption != null) {

            onOptionCreated(state.createdOption!);
            // ✅ 2. NOVA AÇÃO: Chama o método para limpar o formulário.
            context.read<ComplementFormCubit>().clearForm();
          }
        },
        // 3. Constrói a UI com base no estado atual
        child: BlocBuilder<ComplementFormCubit, ComplementFormState>(
          builder: (context, state) {
            final cubit = context.read<ComplementFormCubit>();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [








                const SizedBox(height: 24),
                const Text("Tipo de produto", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(value: true, label: Text("Preparado")),
                    ButtonSegment<bool>(value: false, label: Text("Industrializado")),
                  ],
                  selected: {state.isPrepared},
                  onSelectionChanged: (selection) => cubit.toggleProductType(selection.first),
                ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: state.isPrepared
                      ? PreparedFormView(key: const ValueKey('prepared'))
                      : IndustrializedFlowView(key: const ValueKey('industrialized')),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}



