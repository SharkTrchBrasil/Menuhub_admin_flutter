// features/variants/cubit/variant_edit_state.dart

part of 'variant_edit_cubit.dart';

// ✅ 1. ADICIONE ESTE ENUM PARA CONTROLAR O STATUS DA ABA DE PRODUTOS
enum LinkedProductsStatus { initial, loading, success, error }

class VariantEditState extends Equatable {
  final VariantEditStatus status;
  final Variant originalVariant;
  final Variant editableVariant;
  final String? errorMessage;

  // ✅ 2. ADICIONE OS NOVOS CAMPOS AQUI
  final List<ProductVariantLink> linkedProducts;
  final LinkedProductsStatus linkedProductsStatus;

  const VariantEditState({
    required this.status,
    required this.originalVariant,
    required this.editableVariant,
    this.errorMessage,
    // ✅ 3. ADICIONE-OS AO CONSTRUTOR COM VALORES PADRÃO
    this.linkedProducts = const [],
    this.linkedProductsStatus = LinkedProductsStatus.initial,
  });

  factory VariantEditState.initial(Variant variant) {
    return VariantEditState(
      status: VariantEditStatus.initial,
      originalVariant: variant,
      editableVariant: variant.copyWith(
        options: List<VariantOption>.from(
          variant.options.map((opt) => opt.copyWith()),
        ),
      ),
    );
  }

  bool get hasChanges {
    // A sua lógica de 'hasChanges' pode precisar de ser atualizada
    // para também verificar se a lista de `linkedProducts` mudou.
    // Por agora, vamos manter a verificação simples.
    return originalVariant != editableVariant;
  }

  // ✅ 4. ATUALIZE O MÉTODO `copyWith`
  VariantEditState copyWith({
    VariantEditStatus? status,
    Variant? editableVariant,
    String? errorMessage,
    List<ProductVariantLink>? linkedProducts,
    LinkedProductsStatus? linkedProductsStatus,
  }) {
    return VariantEditState(
      status: status ?? this.status,
      originalVariant: originalVariant,
      editableVariant: editableVariant ?? this.editableVariant,
      errorMessage: errorMessage,
      linkedProducts: linkedProducts ?? this.linkedProducts,
      linkedProductsStatus: linkedProductsStatus ?? this.linkedProductsStatus,
    );
  }

  // ✅ 5. ADICIONE OS NOVOS CAMPOS À LISTA DE `props`
  @override
  List<Object?> get props => [
    status,
    editableVariant,
    errorMessage,
    hasChanges,
    linkedProducts,
    linkedProductsStatus,
  ];
}