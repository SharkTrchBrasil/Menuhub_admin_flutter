import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';


import 'package:totem_pro_admin/repositories/category_repository.dart';
import 'package:totem_pro_admin/models/category.dart';

import '../../../core/enums/available_type.dart';
import '../../../core/enums/cashback_type.dart';
import '../../../core/enums/category_type.dart';
import '../../../core/enums/form_status.dart';
import '../../../core/enums/wizard_step.dart';
import '../../../models/availability_model.dart';
import '../../../models/option_group.dart';
import '../../../models/option_item.dart';
import '../../../models/pizza_model.dart';


part 'category_wizard_state.dart';

class CategoryWizardCubit extends Cubit<CategoryWizardState> {
  final CategoryRepository categoryRepository;
  final int storeId;
  final _uuid = const Uuid();



  CategoryWizardCubit({
    required this.categoryRepository,
    required this.storeId,
    Category? editingCategory, // Parâmetro opcional para o modo de edição
  }) : super(CategoryWizardState.initial()) {

    if (editingCategory != null) {
      final category = editingCategory; // Renomeia para facilitar a leitura

      // Lógica de tradução inversa para Tamanhos
      final sizeGroup = category.optionGroups.firstWhere(
            (g) => g.name == 'Tamanho',
        orElse: () => OptionGroup(name: 'Tamanho', items: [], minSelection: 1, maxSelection: 1),
      );
      final sizes = sizeGroup.items.map((item) => PizzaSize(
        dbId: item.id,
        id: _uuid.v4(),
        name: item.name,
        slices: item.slices ?? 0,
        flavors: item.maxFlavors ?? 1,
        externalCode: item.externalCode ?? '',
        isActive: item.isActive,
      )).toList();

      // Lógica de tradução inversa para Massas
      final doughGroup = category.optionGroups.firstWhere(
            (g) => g.name == 'Massa',
        orElse: () => OptionGroup(name: 'Massa', items: [], minSelection: 1, maxSelection: 1),
      );
      final doughs = doughGroup.items.map((item) => PizzaOption(
        dbId: item.id,
        id: _uuid.v4(),
        name: item.name,
        price: item.price,
        isAvailable: item.isActive,
        externalCode: item.externalCode ?? '',
      )).toList();

      // Lógica de tradução inversa para Bordas
      final edgeGroup = category.optionGroups.firstWhere(
            (g) => g.name == 'Borda',
        orElse: () => OptionGroup(name: 'Borda', items: [], minSelection: 1, maxSelection: 1),
      );
      final edges = edgeGroup.items.map((item) => PizzaOption(
        dbId: item.id,
        id: _uuid.v4(),
        name: item.name,
        price: item.price,
        isAvailable: item.isActive,
        externalCode: item.externalCode ?? '',
      )).toList();

      // Lógica de disponibilidade inteligente
      final availabilityTypeForUI = category.schedules.isNotEmpty
          ? AvailabilityType.scheduled
          : category.availabilityType;

      // Emite o estado inicial já configurado para a edição
      emit(state.copyWith(
        step: WizardStep.details, // JÁ COMEÇA NO PASSO CERTO
        editingCategoryId: category.id,
        categoryType: category.type,
        categoryName: category.name,
        isActive: category.active,
        priority: category.priority.toString(),
        cashbackType: category.cashbackType,
        cashbackValue: category.cashbackValue.toStringAsFixed(2),
        printerDestination: category.printerDestination ?? '',
        pizzaSizes: sizes,
        pizzaDoughs: doughs,
        pizzaEdges: edges,
        availabilityType: availabilityTypeForUI,
        schedules: category.schedules,
      ));
    }
    // Se 'editingCategory' for nulo, o estado inicial padrão é usado (para criação).
  }

  void selectCategoryType(CategoryType type) {
    var newState = state.copyWith(
      categoryType: type,
      step: WizardStep.details,
    );
    if (type == CategoryType.CUSTOMIZABLE) {
      newState = newState.copyWith(

        // ✅ ATUALIZADO: A lista inicial agora contém todos os novos campos
        pizzaSizes: [
          PizzaSize(
            id: _uuid.v4(),
            name: 'Pequena',
            slices: 4, // 'slices' no seu CUBIT, 'pieces' no seu novo modelo. Vamos manter 'slices' por enquanto.
            flavors: 1,
            externalCode: '',
            imageUrl: 'https://portal.ifood.com.br/partner-portal-catalog-experience-web-front/static/svg/default-empty-image.d17ebb88.svg',
            // status: false // Adicione se tiver um campo 'status' ou 'isActive' no seu modelo PizzaSize
          ),
          PizzaSize(
            id: _uuid.v4(),
            name: 'Média',
            slices: 6,
            flavors: 2,
            externalCode: '',
            imageUrl: 'https://portal.ifood.com.br/partner-portal-catalog-experience-web-front/static/svg/pizza-toppings-2.c7b86c10.svg',
          ),
          PizzaSize(
            id: _uuid.v4(),
            name: 'Grande',
            slices: 8,
            flavors: 3,
            externalCode: '',
            imageUrl: 'https://portal.ifood.com.br/partner-portal-catalog-experience-web-front/static/svg/pizza-toppings-3.21d8086e.svg',
          ),
        ],

        pizzaDoughs: [PizzaOption(id: _uuid.v4(), name: 'Tradicional')],
        pizzaEdges: [PizzaOption(id: _uuid.v4(), name: 'Tradicional')],
      );
    }
    emit(newState);
  }

  void updateCategoryName(String name) {
    emit(state.copyWith(categoryName: name));
  }

  void goToTypeSelection() {
    emit(state.copyWith(step: WizardStep.typeSelection));
  }


  // ✅ --- ADICIONE OS MÉTODOS PARA BORDAS DE PIZZA AQUI --- ✅
  void addPizzaEdge() {
    // A borda pode ter um preço inicial, ex: borda de catupiry
    final newEdge = PizzaOption(id: _uuid.v4(), name: 'Nova Borda', price: 500); // R$ 5,00
    final updatedList = List<PizzaOption>.from(state.pizzaEdges)..add(newEdge);
    emit(state.copyWith(pizzaEdges: updatedList));
  }

  void updatePizzaEdge(PizzaOption updatedEdge) {
    final updatedList = state.pizzaEdges.map((edge) {
      return edge.id == updatedEdge.id ? updatedEdge : edge;
    }).toList();
    emit(state.copyWith(pizzaEdges: updatedList));
  }

  void removePizzaEdge(String id) {
    final updatedList = List<PizzaOption>.from(state.pizzaEdges)..removeWhere((edge) => edge.id == id);
    emit(state.copyWith(pizzaEdges: updatedList));
  }

  // ✅ NOVO MÉTODO PARA REORDENAR A LISTA
  void reorderPizzaSize(int oldIndex, int newIndex) {
    // Copia a lista atual do estado
    final List<PizzaSize> reorderedList = List.from(state.pizzaSizes);

    // Remove o item da sua posição antiga
    final PizzaSize item = reorderedList.removeAt(oldIndex);

    // Corrige o índice se o item for movido para baixo na lista
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    // Insere o item na nova posição
    reorderedList.insert(newIndex, item);

    // Emite o novo estado com a lista reordenada
    emit(state.copyWith(pizzaSizes: reorderedList));
  }


  void addPizzaSize() {
    // ✅ ATUALIZADO: O novo tamanho agora é criado com todos os campos necessários
    final newSize = PizzaSize(
      id: _uuid.v4(),
      name: 'Novo Tamanho',
      slices: 0,
      flavors: 1,
      externalCode: '',
      imageUrl: 'https://portal.ifood.com.br/partner-portal-catalog-experience-web-front/static/svg/default-empty-image.d17ebb88.svg',
    );

    final updatedList = List<PizzaSize>.from(state.pizzaSizes)..add(newSize);
    emit(state.copyWith(pizzaSizes: updatedList));
  }

  void updatePizzaSize(PizzaSize updatedSize) {
    final updatedList = state.pizzaSizes.map((size) {
      return size.id == updatedSize.id ? updatedSize : size;
    }).toList();
    emit(state.copyWith(pizzaSizes: updatedList));
  }

  void removePizzaSize(String id) {
    final updatedList = List<PizzaSize>.from(state.pizzaSizes)..removeWhere((size) => size.id == id);
    emit(state.copyWith(pizzaSizes: updatedList));
  }

  // --- GERENCIAMENTO DE MASSAS DE PIZZA ---

  void addPizzaDough() {
    final newDough = PizzaOption(id: _uuid.v4(), name: 'Nova Massa');
    final updatedList = List<PizzaOption>.from(state.pizzaDoughs)..add(newDough);
    emit(state.copyWith(pizzaDoughs: updatedList));
  }

  void updatePizzaDough(PizzaOption updatedDough) {
    final updatedList = state.pizzaDoughs.map((dough) {
      return dough.id == updatedDough.id ? updatedDough : dough;
    }).toList();
    emit(state.copyWith(pizzaDoughs: updatedList));
  }

  void removePizzaDough(String id) {
    final updatedList = List<PizzaOption>.from(state.pizzaDoughs)..removeWhere((dough) => dough.id == id);
    emit(state.copyWith(pizzaDoughs: updatedList));
  }



  // Em: CategoryWizardCubit
// ✅ MÉTODO PARA SUBMETER OS DADOS (CORRIGIDO E COMPLETO)

  Future<void> submitCategory() async {
    if (state.categoryName.trim().isEmpty || state.categoryType == null) return;

    emit(state.copyWith(status: FormStatus.loading));

    // Prepara a lista de grupos de opções
    List<OptionGroup> optionGroups = [];
    if (state.categoryType == CategoryType.CUSTOMIZABLE) {
      optionGroups = _mapStateToOptionGroups();
    }


    final categoryData = Category(
      id: state.editingCategoryId,
      name: state.categoryName.trim(),
      type: state.categoryType!,
      active: state.isActive,
      priority: int.tryParse(state.priority) ?? 0,
      cashbackType: state.cashbackType,
      cashbackValue: double.tryParse(state.cashbackValue.replaceAll(',', '.')) ?? 0.0,
      printerDestination: state.printerDestination.isNotEmpty ? state.printerDestination : null,

      optionGroups: optionGroups,
      schedules: state.schedules,
      availabilityType: state.availabilityType,
    );

    // O resto da lógica de chamada ao repositório continua igual
    final result = (state.editingCategoryId != null)
        ? await categoryRepository.updateCategory(storeId, categoryData)
        : await categoryRepository.createCategory(storeId, categoryData);

    result.fold(
          (error) {
        if (!isClosed) {
          emit(state.copyWith(status: FormStatus.error, errorMessage: error));
        }
      },
          (success) {
        if (!isClosed) {
          emit(state.copyWith(status: FormStatus.success, createdCategory: success));
        }
      },
    );
  }


  // ✅ NOVO MÉTODO PARA ATUALIZAR O ESTADO
  void printerDestinationChanged(String value) {
    emit(state.copyWith(printerDestination: value));
  }












  void isActiveChanged(bool newStatus) {
    emit(state.copyWith(isActive: newStatus));
  }

  void priorityChanged(String newPriority) {
    emit(state.copyWith(priority: newPriority));
  }
  // ✨ NOVO MÉTODO PARA CANCELAR O FLUXO
  void cancelWizard() {
    emit(state.copyWith(status: FormStatus.cancelled));
  }
  void cashbackTypeChanged(CashbackType newType) {
    // Zera o valor se o tipo for "Nenhum"
    final newCashbackValue = (newType == CashbackType.none) ? '0.00' : state.cashbackValue;
    emit(state.copyWith(
      cashbackType: newType,
      cashbackValue: newCashbackValue,
    ));
  }

  void cashbackValueChanged(String newValue) {
    emit(state.copyWith(cashbackValue: newValue));
  }





  List<OptionGroup> _mapStateToOptionGroups() {
    final sizesGroup = OptionGroup(
      name: 'Tamanho',
      minSelection: 1,
      maxSelection: 1,
      items: state.pizzaSizes.map((s) => OptionItem(
        id: s.dbId, // Envia o ID do banco para o backend saber qual item atualizar
        name: s.name,
        slices: s.slices,
        maxFlavors: s.flavors,
        externalCode: s.externalCode,
        isActive: s.isActive,
      )).toList(),
    );

    final doughsGroup = OptionGroup(
      name: 'Massa',
      minSelection: 1,
      maxSelection: 1,
      items: state.pizzaDoughs.map((d) => OptionItem(
        id: d.dbId, // ✅ CORREÇÃO: Enviamos o ID do banco para o update
        name: d.name,
        price: d.price,
        isActive: d.isAvailable,
        externalCode: d.externalCode,
      )).toList(),
    );

    final edgesGroup = OptionGroup(
      name: 'Borda',
      minSelection: 0,
      maxSelection: 1,
      items: state.pizzaEdges.map((e) => OptionItem(
        id: e.dbId, // ✅ CORREÇÃO: E aqui também
        name: e.name,
        price: e.price,
        isActive: e.isAvailable,
        externalCode: e.externalCode,
      )).toList(),
    );

    final flavorsGroup = OptionGroup(name: 'Sabores', minSelection: 1, maxSelection: 4, items: []);

    return [sizesGroup, doughsGroup, edgesGroup, flavorsGroup];
  }

  void availabilityTypeChanged(AvailabilityType newType) {
    if (newType == AvailabilityType.always) {
      // Se o usuário escolher "Sempre disponível", limpamos as regras agendadas
      // para não guardar dados desnecessários.
      emit(state.copyWith(
        availabilityType: newType,
        schedules: [], // Limpa a lista
      ));
    } else {
      // Se o usuário escolher "Agendado"...
      List<ScheduleRule> newSchedules = List.from(state.schedules);


      if (newSchedules.isEmpty) {
        // ✅ CORREÇÃO APLICADA AQUI
        // O uuid (String) vai para o 'localId'. O 'id' (int?) fica nulo, pois é um item novo.
        newSchedules.add(ScheduleRule(localId: _uuid.v4()));
      }

      // Emitimos o novo estado com o tipo e a lista de regras garantida.
      emit(state.copyWith(
        availabilityType: newType,
        schedules: newSchedules,
      ));
    }
  }

  void toggleDay(int ruleIndex, int dayIndex) {
    final List<ScheduleRule> updatedSchedules = List.from(state.schedules);
    final ruleToUpdate = updatedSchedules[ruleIndex];

    final List<bool> updatedDays = List.from(ruleToUpdate.days);
    updatedDays[dayIndex] = !updatedDays[dayIndex];

    updatedSchedules[ruleIndex] = ruleToUpdate.copyWith(days: updatedDays);
    emit(state.copyWith(schedules: updatedSchedules));
  }

  void updateShiftTime(int ruleIndex, int shiftIndex, TimeOfDay newTime, {required bool isStart}) {
    final List<ScheduleRule> updatedSchedules = List.from(state.schedules);
    final ruleToUpdate = updatedSchedules[ruleIndex];

    final List<TimeShift> updatedShifts = List.from(ruleToUpdate.shifts);
    final shiftToUpdate = updatedShifts[shiftIndex];

    updatedShifts[shiftIndex] = isStart
        ? shiftToUpdate.copyWith(startTime: newTime)
        : shiftToUpdate.copyWith(endTime: newTime);

    updatedSchedules[ruleIndex] = ruleToUpdate.copyWith(shifts: updatedShifts);
    emit(state.copyWith(schedules: updatedSchedules));
  }

  void addShift(int ruleIndex) {
    final List<ScheduleRule> updatedSchedules = List.from(state.schedules);
    final ruleToUpdate = updatedSchedules[ruleIndex];

    final List<TimeShift> updatedShifts = List.from(ruleToUpdate.shifts)..add(const TimeShift());

    updatedSchedules[ruleIndex] = ruleToUpdate.copyWith(shifts: updatedShifts);
    emit(state.copyWith(schedules: updatedSchedules));
  }

  void removeShift(int ruleIndex, int shiftIndex) {
    final List<ScheduleRule> updatedSchedules = List.from(state.schedules);
    final ruleToUpdate = updatedSchedules[ruleIndex];

    final List<TimeShift> updatedShifts = List.from(ruleToUpdate.shifts);
    if (updatedShifts.length > 1) { // Só permite remover se houver mais de um
      updatedShifts.removeAt(shiftIndex);
    }

    updatedSchedules[ruleIndex] = ruleToUpdate.copyWith(shifts: updatedShifts);
    emit(state.copyWith(schedules: updatedSchedules));
  }



}