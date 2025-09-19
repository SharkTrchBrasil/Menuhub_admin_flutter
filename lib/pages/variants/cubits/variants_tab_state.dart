part of 'variants_tab_cubit.dart';

enum VariantsTabStatus { initial, loading, success, error }

class VariantsTabState extends Equatable {
  final VariantsTabStatus status;
  final List<Variant> allVariants;
  final String searchText;
  final Set<int> selectedVariantIds;
  final String? errorMessage;
  final String? successMessage;

  const VariantsTabState({
    this.status = VariantsTabStatus.initial,
    this.allVariants = const [],
    this.searchText = '',
    this.selectedVariantIds = const {},
    this.errorMessage,
    this.successMessage,
  });

  // GETTER: A UI não precisa mais filtrar. O estado já entrega a lista pronta.
  List<Variant> get filteredVariants => searchText.isEmpty
      ? allVariants
      : allVariants
      .where((v) => v.name.toLowerCase().contains(searchText.toLowerCase()))
      .toList();

  VariantsTabState copyWith({
    VariantsTabStatus? status,
    List<Variant>? allVariants,
    String? searchText,
    Set<int>? selectedVariantIds,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return VariantsTabState(
      status: status ?? this.status,
      allVariants: allVariants ?? this.allVariants,
      searchText: searchText ?? this.searchText,
      selectedVariantIds: selectedVariantIds ?? this.selectedVariantIds,
      errorMessage: clearMessages ? null : errorMessage,
      successMessage: clearMessages ? null : successMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allVariants,
    searchText,
    selectedVariantIds,
    errorMessage,
    successMessage,
  ];
}