// lib/.../widgets/complement_form_cubit.dart
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/models/catalog_product.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/models/variant_option.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';

import '../../../core/enums/form_status.dart';

// 1. O ESTADO: Descreve como a UI deve se parecer em qualquer momento.
class ComplementFormState extends Equatable {
  final bool isPrepared;
  final bool isLoadingSearch;
  final List<CatalogProduct> searchResults;
  final CatalogProduct? selectedCatalogProduct;
  final ImageModel image;
  final bool trackInventory;
  final String stockQuantity;
  final String name;
  final String description;
  final String price;
  final VariantOption? createdOption; // Para notificar a UI quando uma opção for criada

  const ComplementFormState({
    this.isPrepared = true,
    this.isLoadingSearch = false,
    this.searchResults = const [],
    this.selectedCatalogProduct,
    this.image =  const ImageModel(),
    this.trackInventory = false,
    this.stockQuantity = '0',
    this.name = '',
    this.description = '',
    this.price = '',
    this.createdOption,
  });

  ComplementFormState copyWith({
    bool? isPrepared,
    bool? isLoadingSearch,
    List<CatalogProduct>? searchResults,
    CatalogProduct? selectedCatalogProduct,
    bool clearSelectedProduct = false,
    ImageModel? image,
    bool? trackInventory,
    String? stockQuantity,
    String? name,
    String? description,
    String? price,
    VariantOption? createdOption,
    bool clearCreatedOption = false,
  }) {
    return ComplementFormState(
      isPrepared: isPrepared ?? this.isPrepared,
      isLoadingSearch: isLoadingSearch ?? this.isLoadingSearch,
      searchResults: searchResults ?? this.searchResults,
      selectedCatalogProduct: clearSelectedProduct ? null : selectedCatalogProduct ?? this.selectedCatalogProduct,
      image: image ?? this.image,
      trackInventory: trackInventory ?? this.trackInventory,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      createdOption: clearCreatedOption ? null : createdOption ?? this.createdOption,
    );
  }

  @override
  List<Object?> get props => [
    isPrepared,
    isLoadingSearch,
    searchResults,
    selectedCatalogProduct,
    image,
    trackInventory,
    stockQuantity,
    name,
    description,
    price,
    createdOption,
  ];
}

// 2. O CUBIT: Contém toda a lógica de negócio do formulário.
class ComplementFormCubit extends Cubit<ComplementFormState> {
  final ProductRepository _productRepository = getIt<ProductRepository>();
  Timer? _debounce;

  ComplementFormCubit() : super( ComplementFormState());

  void toggleProductType(bool isPrepared) {
    emit(state.copyWith(isPrepared: isPrepared));
    if (!isPrepared) {
      resetIndustrializedFlow();
    }
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.length >= 3) {
        _performSearch(query);
      } else {
        emit(state.copyWith(searchResults: []));
      }
    });
  }

  Future<void> _performSearch(String query) async {
    emit(state.copyWith(isLoadingSearch: true));
    final result = await _productRepository.searchMasterProducts(query);
    result.fold(
          (error) => print("Erro na busca: $error"),
          (products) => emit(state.copyWith(searchResults: products)),
    );
    emit(state.copyWith(isLoadingSearch: false));
  }

  void selectCatalogProduct(CatalogProduct product) {
    emit(state.copyWith(
      selectedCatalogProduct: product,
      name: product.name,
      description: product.description ?? '',
      image: ImageModel(url: product.imagePath?.url),
    ));
  }

  void resetIndustrializedFlow() {
    emit(state.copyWith(
      clearSelectedProduct: true,
      searchResults: [],
      name: '',
      description: '',
      price: '',
      image: ImageModel(),
    ));
  }

  // Métodos para atualizar cada campo do formulário
  void nameChanged(String value) => emit(state.copyWith(name: value));
  void descriptionChanged(String value) => emit(state.copyWith(description: value));
  void priceChanged(String value) => emit(state.copyWith(price: value));
  void imageChanged(ImageModel? image) => emit(state.copyWith(image: image ?? ImageModel()));
  void trackInventoryChanged(bool value) => emit(state.copyWith(trackInventory: value));
  void stockQuantityChanged(String value) => emit(state.copyWith(stockQuantity: value));

// DENTRO DA CLASSE ComplementFormCubit

  void submit() {
    final newOption = VariantOption(
      name_override: state.name.trim(),
      description: state.description.trim(),
      price_override: ((double.tryParse(state.price.replaceAll(',', '.')) ?? 0) * 100).toInt(),
      image: state.image,
      track_inventory: state.trackInventory,
      stock_quantity: int.tryParse(state.stockQuantity) ?? 0,
      available: true,
    );

    // Apenas emita o estado com a opção criada. O Listener na UI cuidará do resto.
    emit(state.copyWith(createdOption: newOption));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}