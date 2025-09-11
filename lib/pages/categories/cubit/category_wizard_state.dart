part of 'category_wizard_cubit.dart';

class CategoryWizardState extends Equatable {
  final WizardStep step;
  final FormStatus status;
  final String? errorMessage;

  // --- Dados da Categoria ---
  final int? editingCategoryId;
  final CategoryType? categoryType;
  final String categoryName;
  final bool isActive;
  final String priority;
  final CashbackType cashbackType;
  final String cashbackValue;
  final String printerDestination;

  // --- Disponibilidade ---
  final AvailabilityType availabilityType;
  final List<ScheduleRule> schedules;

  // ✅ A GRANDE MUDANÇA: UMA ÚNICA LISTA GENÉRICA PARA GRUPOS DE OPÇÕES
  final List<OptionGroup> optionGroups;
  final PricingStrategy pricingStrategy;

  // Dados de retorno
  final Category? createdCategory;
  final bool priceVariesBySize;


  const CategoryWizardState({
    this.step = WizardStep.typeSelection,
    this.status = FormStatus.initial,
    this.errorMessage,
    this.editingCategoryId,
    this.categoryType,
    this.categoryName = '',
    this.isActive = true,
    this.priority = '0',
    this.cashbackType = CashbackType.none,
    this.cashbackValue = '0.00',
    this.printerDestination = '',
    this.availabilityType = AvailabilityType.always,
    this.schedules = const [],
    this.optionGroups = const [], // ✅ Inicializa a lista genérica
    this.createdCategory,
    this.pricingStrategy = PricingStrategy.sumOfItems,
    this.priceVariesBySize = false,
  });

  factory CategoryWizardState.initial() => const CategoryWizardState();

  // ✅ NOVO FACTORY CONSTRUCTOR PARA O MODO DE EDIÇÃO
  // Ele pega uma categoria do banco e a "traduz" para o estado da UI.
  factory CategoryWizardState.fromCategory(Category category) {
    final uuid = const Uuid();
    return CategoryWizardState(
      step: WizardStep.details,
      editingCategoryId: category.id,
      categoryType: category.type,
      categoryName: category.name,
      isActive: category.active,
      priority: category.priority.toString(),
      cashbackType: category.cashbackType,
      cashbackValue: category.cashbackValue.toStringAsFixed(2),
      printerDestination: category.printerDestination ?? '',
      availabilityType: category.schedules.isNotEmpty
          ? AvailabilityType.scheduled
          : category.availabilityType,
      schedules: category.schedules,
      pricingStrategy: category.pricingStrategy ?? PricingStrategy.sumOfItems,
      priceVariesBySize: category.priceVariesBySize ?? false,
      // Mapeia os OptionGroups do banco, adicionando um localId para a UI
      // gerenciar adições/remoções antes de salvar.
      optionGroups: category.optionGroups.map((group) {
        return group.copyWith(
          localId: uuid.v4(),
          items: group.items.map((item) => item.copyWith(localId: uuid.v4())).toList(),
        );
      }).toList(),
    );
  }

  CategoryWizardState copyWith({
    WizardStep? step,
    FormStatus? status,
    String? errorMessage,
    int? editingCategoryId,
    CategoryType? categoryType,
    String? categoryName,
    bool? isActive,
    String? priority,
    CashbackType? cashbackType,
    String? cashbackValue,
    String? printerDestination,
    AvailabilityType? availabilityType,
    List<ScheduleRule>? schedules,
    List<OptionGroup>? optionGroups, // ✅ Parâmetro genérico
    Category? createdCategory,
    PricingStrategy? pricingStrategy,
    bool? priceVariesBySize,
  }) {
    return CategoryWizardState(
      step: step ?? this.step,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      editingCategoryId: editingCategoryId ?? this.editingCategoryId,
      categoryType: categoryType ?? this.categoryType,
      categoryName: categoryName ?? this.categoryName,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
      cashbackType: cashbackType ?? this.cashbackType,
      cashbackValue: cashbackValue ?? this.cashbackValue,
      printerDestination: printerDestination ?? this.printerDestination,
      availabilityType: availabilityType ?? this.availabilityType,
      schedules: schedules ?? this.schedules,
      optionGroups: optionGroups ?? this.optionGroups, // ✅ Lógica do copyWith
      createdCategory: createdCategory ?? this.createdCategory,
        pricingStrategy: pricingStrategy ?? this.pricingStrategy,
      priceVariesBySize: priceVariesBySize ?? this.priceVariesBySize,
    );
  }

  @override
  List<Object?> get props => [
    step,
    status,
    errorMessage,
    editingCategoryId,
    categoryType,
    categoryName,
    isActive,
    priority,
    cashbackType,
    cashbackValue,
    printerDestination,
    availabilityType,
    schedules,
    optionGroups, // ✅ Propriedade genérica
    createdCategory,
    pricingStrategy,
    priceVariesBySize,
  ];
}