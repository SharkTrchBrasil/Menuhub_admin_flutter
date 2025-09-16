// lib/pages/product_edit/cubit/create_complement_state.dart

part of 'create_complement_cubit.dart';



enum GroupType { ingredients, specifications, crossSell, disposables }

class CreateComplementGroupState extends Equatable {
  final CreateComplementStep step;
  final FormStatus status;
  final bool isCopyFlow;
  final String? errorMessage;
  final GroupType? groupType;
  final String groupName;
  final bool isRequired;
  final int minQty;
  final int maxQty;
  final List<VariantOption> complements;
  final List<dynamic> itemsAvailableToCopy;
  final Set<int> selectedToCopyIds;
  final Variant? selectedVariantToCopy;

  const CreateComplementGroupState({
    this.step = CreateComplementStep.initial,
    this.status = FormStatus.initial,
    this.isCopyFlow = false,
    this.groupType,
    this.groupName = '',
    this.isRequired = false,
    this.minQty = 0,
    this.maxQty = 1,
    this.complements = const [],
    this.itemsAvailableToCopy = const [],
    this.selectedToCopyIds = const {},
    this.selectedVariantToCopy,
    this.errorMessage,
  });

  factory CreateComplementGroupState.initial() => const CreateComplementGroupState();

  CreateComplementGroupState copyWith({
    CreateComplementStep? step,
    FormStatus? status,
    bool? isCopyFlow,
    GroupType? groupType,
    String? groupName,
    bool? isRequired,
    int? minQty,
    int? maxQty,
    List<VariantOption>? complements,
    List<dynamic>? itemsAvailableToCopy,
    Set<int>? selectedToCopyIds,
    Variant? selectedVariantToCopy,
    String? errorMessage,
  }) {
    return CreateComplementGroupState(
      step: step ?? this.step,
      status: status ?? this.status,
      isCopyFlow: isCopyFlow ?? this.isCopyFlow,
      groupType: groupType ?? this.groupType,
      groupName: groupName ?? this.groupName,
      isRequired: isRequired ?? this.isRequired,
      minQty: minQty ?? this.minQty,
      maxQty: maxQty ?? this.maxQty,
      complements: complements ?? this.complements,
      itemsAvailableToCopy: itemsAvailableToCopy ?? this.itemsAvailableToCopy,
      selectedToCopyIds: selectedToCopyIds ?? this.selectedToCopyIds,
      selectedVariantToCopy: selectedVariantToCopy ?? this.selectedVariantToCopy,
      errorMessage: errorMessage, // Permite limpar a mensagem de erro
    );
  }

  @override
  List<Object?> get props => [
    step, status, isCopyFlow, groupType, groupName, isRequired, minQty, maxQty,
    complements, itemsAvailableToCopy, selectedToCopyIds, selectedVariantToCopy, errorMessage
  ];
}