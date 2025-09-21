import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:totem_pro_admin/core/enums/cashback_type.dart';
import 'package:totem_pro_admin/pages/product_edit/cubit/edit_product_cubit.dart';

import '../../../models/product.dart';

class ProductCashbackTab extends StatelessWidget {
  const ProductCashbackTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditProductCubit, EditProductState>(
      builder: (context, state) {
        final cubit = context.read<EditProductCubit>();


        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _buildCashbackSection(context, cubit, state),
        );
      },
    );
  }

  // Widget principal da aba
  Widget _buildCashbackSection(BuildContext context, EditProductCubit cubit, EditProductState state) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: Colors.purple.shade50, shape: BoxShape.circle),
                  child: Icon(Icons.monetization_on, color: Colors.purple.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                Text("Regra de Cashback", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 16),
            // Dropdown para tipo de cashback
            DropdownButtonFormField<CashbackType>(
              value: state.editedProduct.cashbackType,
              onChanged: cubit.cashbackTypeChanged,
              decoration: InputDecoration(
                labelText: "Tipo de Cashback",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: CashbackType.values.map((type) {
                return DropdownMenuItem<CashbackType>(
                  value: type,
                  child: Text(type.displayName), // Supondo que você tenha um getter 'displayName' no enum
                );
              }).toList(),
            ),
            // Campo de valor apenas se cashback estiver ativo
            if (state.editedProduct.cashbackType != CashbackType.none) ...[
              const SizedBox(height: 16),
              TextFormField(
                key: ValueKey(state.editedProduct.cashbackType), // Força reconstrução ao mudar o tipo
                initialValue: _getInitialCashbackValue(state.editedProduct),
                onChanged: cubit.cashbackValueChanged,
                keyboardType: TextInputType.number,
                inputFormatters: _getCashbackFormatters(state.editedProduct.cashbackType),
                decoration: InputDecoration(
                  labelText: "Valor do Cashback",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixText: state.editedProduct.cashbackType == CashbackType.fixed ? "R\$ " : null,
                  suffixText: state.editedProduct.cashbackType == CashbackType.percentage ? "%" : null,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  String _getInitialCashbackValue(Product product) {
    if (product.cashbackType == CashbackType.fixed) {
      return UtilBrasilFields.obterReal(product.cashbackValue / 100);
    }
    return product.cashbackValue.toString();
  }

  List<TextInputFormatter> _getCashbackFormatters(CashbackType type) {
    if (type == CashbackType.fixed) {
      return [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter()];
    }
    return [FilteringTextInputFormatter.digitsOnly];
  }
}