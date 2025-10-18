import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/enums/foodtags.dart';


import '../../product-wizard/cubit/product_wizard_cubit.dart';
import '../../product-wizard/cubit/product_wizard_state.dart';

class ClassificationTab extends StatelessWidget {
  const ClassificationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductWizardCubit, ProductWizardState>(
      buildWhen: (p, c) => p.productInCreation.dietaryTags != c.productInCreation.dietaryTags,
      builder: (context, state) {
        final cubit = context.read<ProductWizardCubit>();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text('Classificação', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Indique se seu item é adequado a restrições alimentares.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: FoodTag.values.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final tag = FoodTag.values[index];
                  return CheckboxListTile(
                    title: Text(foodTagNames[tag]!),
                    subtitle: Text(foodTagDescriptions[tag]!),
                    value: state.productInCreation.dietaryTags.contains(tag),
                    onChanged: (isSelected) {
                      cubit.toggleDietaryTag(tag);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}