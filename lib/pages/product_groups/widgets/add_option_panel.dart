import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:totem_pro_admin/models/variant.dart';
import 'package:totem_pro_admin/models/variant_option.dart';
import 'package:totem_pro_admin/pages/product_groups/widgets/unifield_product_form.dart';
import 'package:totem_pro_admin/pages/product_groups/widgets/wizard_footer.dart';

import '../../../models/products/product.dart';
import '../cubit/add_option_cubit.dart';
import '../cubit/complement_form_cubit.dart';

class AddOptionPanel extends StatelessWidget {
  final List<Product> allProducts;
  final List<Variant> allVariants;

  const AddOptionPanel({
    super.key,
    required this.allProducts,
    required this.allVariants,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddOptionCubit(
        allProducts: allProducts,
        allVariants: allVariants,
      ),
      child: BlocListener<AddOptionCubit, AddOptionState>(
        listener: (context, state) {
          if (state.status == FormStatus.success && state.result != null) {
            context.pop(state.result);
          }
        },
        child: BlocBuilder<AddOptionCubit, AddOptionState>(
          builder: (context, state) {
            return PageView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                if (state.step == AddOptionStep.initialChoice)
                  _buildInitialChoice(context),
                if (state.step == AddOptionStep.creationForm)
                  _buildCreationForm(context),
                if (state.step == AddOptionStep.copyList)
                  _buildCopyList(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInitialChoice(BuildContext context) {
    final cubit = context.read<AddOptionCubit>();
    return Container(
      color: Colors.white,
      child: Column(
        children: [
         SizedBox(height: 24,),
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Adicionar complemento",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF151515),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Adicione um complemento ao grupo",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),

          // Body with options
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Create new option button
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Material(
                      color: Colors.white,
                      child: InkWell(
                        onTap: cubit.showCreateNewFlow,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.add, color: Color(0xFF151515)),
                              const SizedBox(width: 16),
                              const Text(
                                "Criar novo complemento",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF151515),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Copy option button
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Material(
                      color: Colors.white,
                      child: InkWell(
                        onTap: cubit.showCopyFlow,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.link, color: Color(0xFF151515)),
                              const SizedBox(width: 16),
                              const Text(
                                "Copiar complemento",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF151515),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "Voltar",
                    style: TextStyle(color: Color(0xFF151515)),
                  ),
                ),
                ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEB0033),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: const Text("Concluir"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreationForm(BuildContext context) {
    final addOptionCubit = context.read<AddOptionCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Criar novo complemento"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: addOptionCubit.goBackToChoice,
        ),
      ),
      body: BlocProvider(
        create: (_) => ComplementFormCubit(),
        child: BlocListener<ComplementFormCubit, ComplementFormState>(
          listener: (context, state) {
            if (state.createdOption != null) {
              addOptionCubit.submitNewOption(state.createdOption!);
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: UnifiedProductForm(isPrepared: true),
          ),
        ),
      ),

    );
  }

  Widget _buildCopyList(BuildContext context) {
    final cubit = context.read<AddOptionCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Copiar complemento"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: cubit.goBackToChoice,
        ),
      ),
      body: const Center(
        child: Text("Tela de busca e seleção de itens para copiar (a ser implementada)."),
      ),
    );
  }
}