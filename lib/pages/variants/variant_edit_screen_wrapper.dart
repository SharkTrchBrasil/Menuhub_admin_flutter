import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/models/variant.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';

import 'cubits/variant_edit_cubit.dart';
import 'edit_variants.dart';


class VariantEditScreenWrapper extends StatelessWidget {
  final int storeId;
  final Variant variant;

  const VariantEditScreenWrapper({
    super.key,
    required this.variant,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    // A única função deste widget é criar e prover o Cubit
    return BlocProvider(
      create: (_) => VariantEditCubit(
        initialVariant: variant,
        productRepository: getIt<ProductRepository>(),
        storeId: storeId,
      ),
      // E então construir a tela da UI, que agora terá acesso ao Cubit
      child:  VariantEditScreen(storeId: storeId,),
    );
  }
}