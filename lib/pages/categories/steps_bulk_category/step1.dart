import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/category.dart';
import '../cubit/bulk_category_cubit.dart';
import '../cubit/bulk_category_state.dart';


class Step1SelectCategory extends StatelessWidget {
  final List<Category> allCategories;
  const Step1SelectCategory({super.key, required this.allCategories});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BulkAddToCategoryCubit, BulkAddToCategoryState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "Escolha uma categoria do seu cardápio",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<Category>(
                value: state.targetCategory,
                hint: const Text("Selecione a categoria de destino"),
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Categorias',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: allCategories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat.name)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    context.read<BulkAddToCategoryCubit>().selectCategory(val);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}