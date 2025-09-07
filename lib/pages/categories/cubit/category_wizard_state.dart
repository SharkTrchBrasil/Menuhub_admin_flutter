part of 'category_wizard_cubit.dart';

class CategoryWizardState extends Equatable {
  final WizardStep step;
  final FormStatus status;
  final String? errorMessage; // ✨ CAMPO ADICIONADO

  final CategoryType? categoryType;
  final String categoryName;
  final bool isActive;
  final String priority;
  final CashbackType cashbackType;
  final String cashbackValue;

  // Estados específicos para o fluxo Customizável (Pizza)
  final List<PizzaSize> pizzaSizes;
  final List<PizzaOption> pizzaDoughs;
  final List<PizzaOption> pizzaEdges;

  // Estados para disponibilidade
  final AvailabilityType availabilityType;
  final List<ScheduleRule> schedules;
  final int? editingCategoryId;
  final Category? createdCategory;
  final String printerDestination;

  const CategoryWizardState({
    this.step = WizardStep.typeSelection,
    this.status = FormStatus.initial,
    this.errorMessage, // ✨
    this.categoryType,
    this.categoryName = '',
    this.isActive = true,
    this.priority = '0',
    this.cashbackType = CashbackType.none,
    this.cashbackValue = '0.00',
    this.pizzaSizes = const [],
    this.pizzaDoughs = const [],
    this.pizzaEdges = const [],
    this.availabilityType = AvailabilityType.always,
    this.schedules = const [],
    this.editingCategoryId,
    this.createdCategory,
    this.printerDestination = '', // ✨
  });

  factory CategoryWizardState.initial() => const CategoryWizardState();

  CategoryWizardState copyWith({
    WizardStep? step,
    FormStatus? status,
    String? errorMessage, // ✨
    CategoryType? categoryType,
    String? categoryName,
    bool? isActive,
    String? priority,
    CashbackType? cashbackType,
    String? cashbackValue,
    List<PizzaSize>? pizzaSizes,
    List<PizzaOption>? pizzaDoughs,
    List<PizzaOption>? pizzaEdges,
    AvailabilityType? availabilityType,
    List<ScheduleRule>? schedules,
    int? editingCategoryId,
    Category? createdCategory,
    String? printerDestination

  }) {
    return CategoryWizardState(
      step: step ?? this.step,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage, // ✨
      categoryType: categoryType ?? this.categoryType,
      categoryName: categoryName ?? this.categoryName,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
      cashbackType: cashbackType ?? this.cashbackType,
      cashbackValue: cashbackValue ?? this.cashbackValue,
      pizzaSizes: pizzaSizes ?? this.pizzaSizes,
      pizzaDoughs: pizzaDoughs ?? this.pizzaDoughs,
      pizzaEdges: pizzaEdges ?? this.pizzaEdges,
      availabilityType: availabilityType ?? this.availabilityType,
      schedules: schedules ?? this.schedules,
      editingCategoryId: editingCategoryId ?? this.editingCategoryId,
      createdCategory: createdCategory ?? this.createdCategory,
      printerDestination: printerDestination ?? this.printerDestination
    );
  }

  @override
  List<Object?> get props => [
    step,
    status,
    errorMessage, // ✨
    categoryType,
    categoryName,
    isActive,
    priority,
    cashbackType,
    cashbackValue,
    pizzaSizes,
    pizzaDoughs,
    pizzaEdges,
    availabilityType,
    schedules,
    editingCategoryId,
    createdCategory,
    printerDestination
  ];
}