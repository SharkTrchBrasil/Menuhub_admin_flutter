import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/product_variant_link.dart';

import '../../../models/variant.dart';
import '../../../models/variant_option.dart'; // Importe seus modelos

// Enum para os passos do fluxo de criação
enum CreateComplementStep { initial, selectType, groupDetails, addComplements }

// Enum para o status do formulário (ocioso, carregando, sucesso, erro)
enum FormStatus { initial, loading, success, error }
// Enum para os tipos de grupo de complementos
enum GroupType { ingredients, specifications, crossSell, disposables }
// No seu arquivo de modelos, onde VariantType é definido

// A classe de estado principal
class CreateComplementGroupState extends Equatable {
  final CreateComplementStep step;
  final FormStatus status;
  final GroupType? groupType;
  final String groupName;
  final bool isRequired;
  final int minQty;
  final int maxQty;
  final String? errorMessage;
  // Adicione aqui a lista de complementos do passo 3
   final List<VariantOption> complements;

  final List<dynamic> itemsAvailableToCopy;
  // ✅ 1. ADICIONE A PROPRIEDADE AQUI
  final Set<int> selectedToCopyIds;

  // ✅ 1. ADICIONE AS DUAS NOVAS PROPRIEDADES AQUI
  final bool isCopyFlow;
  final Variant? selectedVariantToCopy;

  const CreateComplementGroupState({
    this.step = CreateComplementStep.initial,
    this.status = FormStatus.initial,
    this.groupType,
    this.groupName = '',
    this.isRequired = false,
    this.minQty = 0,
    this.maxQty = 1,
    this.errorMessage,
    this.complements = const [],
    this.itemsAvailableToCopy = const [],
    this.selectedToCopyIds = const {},
    this.isCopyFlow = false,
    this.selectedVariantToCopy,
  });

  // Estado inicial
  factory CreateComplementGroupState.initial() => const CreateComplementGroupState();

  // O método copyWith é essencial para criar novos estados de forma imutável
  CreateComplementGroupState copyWith({
    CreateComplementStep? step,
    FormStatus? status,
    GroupType? groupType,
    String? groupName,
    bool? isRequired,
    int? minQty,
    int? maxQty,
    String? errorMessage,
    List<VariantOption>? complements,
    List<dynamic>? itemsAvailableToCopy,
    // ✅ 3. ADICIONE AO MÉTODO copyWith
    Set<int>? selectedToCopyIds,
    // ✅ 3. ADICIONE AO MÉTODO copyWith
    bool? isCopyFlow,
    Variant? selectedVariantToCopy,

  }) {
    return CreateComplementGroupState(
      step: step ?? this.step,
      status: status ?? this.status,
      groupType: groupType ?? this.groupType,
      groupName: groupName ?? this.groupName,
      isRequired: isRequired ?? this.isRequired,
      minQty: minQty ?? this.minQty,
      maxQty: maxQty ?? this.maxQty,
      errorMessage: errorMessage ?? this.errorMessage,
      complements: complements ?? this.complements,
      itemsAvailableToCopy: itemsAvailableToCopy ?? this.itemsAvailableToCopy,
      // E FAÇA A ATRIBUIÇÃO AQUI
      selectedToCopyIds: selectedToCopyIds ?? this.selectedToCopyIds,
      // E FAÇA A ATRIBUIÇÃO AQUI
      isCopyFlow: isCopyFlow ?? this.isCopyFlow,
      selectedVariantToCopy: selectedVariantToCopy ?? this.selectedVariantToCopy,
    );
  }

  @override
  List<Object?> get props => [step, status, groupType, groupName, isRequired, minQty, maxQty, errorMessage, complements, itemsAvailableToCopy, selectedToCopyIds,   isCopyFlow,
    selectedVariantToCopy,];
}