
// ARQUIVO: category_link_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/models/category.dart';

import 'package:totem_pro_admin/models/products/prodcut_category_links.dart';

import '../../../models/products/product.dart';

part 'category_link_state.dart';

class CategoryLinkCubit extends Cubit<CategoryLinkState> {
  CategoryLinkCubit({required Product product}) : super(CategoryLinkState.initial(product));

  void categorySelected(Category category) {
    emit(state.copyWith(
      linkData: state.linkData.copyWith(category: category, categoryId: category.id),
    ));
  }

  // ✅ MÉTODOS ADICIONADOS PARA O PASSO 2
  void priceChanged(String value) {
    final priceInCents = (UtilBrasilFields.converterMoedaParaDouble(value) * 100).toInt();
    emit(state.copyWith(linkData: state.linkData.copyWith(price: priceInCents)));
  }

  void posCodeChanged(String value) {
    emit(state.copyWith(linkData: state.linkData.copyWith(posCode: value)));
  }

  void nextStep() {
    if(state.linkData.category != null) emit(state.copyWith(currentStep: 2));
  }

  void previousStep() {
    emit(state.copyWith(currentStep: 1));
  }

  void submitLink() {
    emit(state.copyWith(status: FormStatus.success));
  }
}