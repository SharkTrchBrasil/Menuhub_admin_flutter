import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// Seus imports
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/option_group.dart';
import 'package:totem_pro_admin/models/option_item.dart';
import 'package:totem_pro_admin/repositories/category_repository.dart';
import 'package:totem_pro_admin/models/availability_model.dart';
import 'package:totem_pro_admin/core/enums/available_type.dart';
import 'package:totem_pro_admin/core/enums/cashback_type.dart';
import 'package:totem_pro_admin/core/enums/category_type.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/core/enums/wizard_step.dart';

import '../../../core/enums/pricing_strategy.dart';

part 'category_wizard_state.dart';

class CategoryWizardCubit extends Cubit<CategoryWizardState> {
  final CategoryRepository categoryRepository;
  final int storeId;
  final _uuid = const Uuid();

  CategoryWizardCubit({
    required this.categoryRepository,
    required this.storeId,
    Category? editingCategory,
  }) : super(
    editingCategory == null
        ? CategoryWizardState.initial()
        : CategoryWizardState.fromCategory(editingCategory),
  );

  // --- NAVEGAÇÃO DO WIZARD ---
  // ATUALIZE ESTE MÉTODO
  void selectCategoryType(CategoryType type) {
    // Se for Geral, vai direto para os detalhes.
    if (type == CategoryType.GENERAL) {
      emit(state.copyWith(
        categoryType: type,
        step: WizardStep.details,
      ));
    }
    // Se for Customizável, agora vai para a tela de templates.
    else {
      emit(state.copyWith(
        categoryType: type,
        step: WizardStep.pricingModelSelection,// ✅ MUDANÇA AQUI
      ));
    }
  }

  // ✅ ESTE MÉTODO SERÁ CHAMADO PELA NOVA TELA
  void setPricingModel({required bool variesBySize}) {
    emit(state.copyWith(
      priceVariesBySize: variesBySize,
      // Após escolher o modelo, vamos para a seleção de templates
      step: WizardStep.templateSelection,
    ));
  }
  // ✅ NOVO MÉTODO PARA APLICAR UM TEMPLATE
  void applyTemplate(List<OptionGroup> groups) {
    emit(state.copyWith(
      optionGroups: groups,
      step: WizardStep.details, // Avança para os detalhes após aplicar
    ));
  }



  void goToTypeSelection() {
    emit(state.copyWith(step: WizardStep.typeSelection));
  }


  // ✅ ADICIONE ESTE NOVO MÉTODO
  void updateGroupPricingStrategy(String groupLocalId, PricingStrategy strategy) {
    final updatedGroups = state.optionGroups.map((group) {
      if (group.localId == groupLocalId) {
        return group.copyWith(pricingStrategy: strategy);
      }
      return group;
    }).toList();
    emit(state.copyWith(optionGroups: updatedGroups));
  }

  // --- AÇÕES DE DADOS BÁSICOS DA CATEGORIA ---
  void updateCategoryName(String name) => emit(state.copyWith(categoryName: name));
  void isActiveChanged(bool newStatus) => emit(state.copyWith(isActive: newStatus));
  void priorityChanged(String newPriority) => emit(state.copyWith(priority: newPriority));
  void printerDestinationChanged(String value) => emit(state.copyWith(printerDestination: value));
  void cashbackTypeChanged(CashbackType newType) {
    final newCashbackValue = (newType == CashbackType.none) ? '0.00' : state.cashbackValue;
    emit(state.copyWith(cashbackType: newType, cashbackValue: newCashbackValue));
  }
  void cashbackValueChanged(String newValue) => emit(state.copyWith(cashbackValue: newValue));

  // --- GERENCIAMENTO DE GRUPOS DE OPÇÕES (GENÉRICO) ---
  void addOptionGroup() {
    final newGroup = OptionGroup(
      localId: _uuid.v4(),
      name: 'Novo Grupo',
      minSelection: 1,
      maxSelection: 1,
      items: [OptionItem(localId: _uuid.v4(), name: 'Nova Opção', isActive: true)],
    );
    final updatedGroups = List<OptionGroup>.from(state.optionGroups)..add(newGroup);
    emit(state.copyWith(optionGroups: updatedGroups));
  }

  void updateOptionGroup(OptionGroup updatedGroup) {
    final updatedList = state.optionGroups.map((group) {
      return group.localId == updatedGroup.localId ? updatedGroup : group;
    }).toList();
    emit(state.copyWith(optionGroups: updatedList));
  }

  void removeOptionGroup(String localId) {
    final updatedList = List<OptionGroup>.from(state.optionGroups)
      ..removeWhere((group) => group.localId == localId);
    emit(state.copyWith(optionGroups: updatedList));
  }

  void reorderOptionGroups(int oldIndex, int newIndex) {
    final reorderedList = List<OptionGroup>.from(state.optionGroups);
    final item = reorderedList.removeAt(oldIndex);
    if (newIndex > oldIndex) newIndex -= 1;
    reorderedList.insert(newIndex, item);
    emit(state.copyWith(optionGroups: reorderedList));
  }

  // --- GERENCIAMENTO DE ITENS DENTRO DE UM GRUPO ---
  void addOptionItem(String groupLocalId) {
    final updatedGroups = state.optionGroups.map((group) {
      if (group.localId == groupLocalId) {
        final newItem = OptionItem(localId: _uuid.v4(), name: 'Nova Opção', isActive: true);
        final updatedItems = List<OptionItem>.from(group.items)..add(newItem);
        return group.copyWith(items: updatedItems);
      }
      return group;
    }).toList();
    emit(state.copyWith(optionGroups: updatedGroups));
  }

  void updateOptionItem(String groupLocalId, OptionItem updatedItem) {
    final updatedGroups = state.optionGroups.map((group) {
      if (group.localId == groupLocalId) {
        final updatedItems = group.items.map((item) {
          return item.localId == updatedItem.localId ? updatedItem : item;
        }).toList();
        return group.copyWith(items: updatedItems);
      }
      return group;
    }).toList();
    emit(state.copyWith(optionGroups: updatedGroups));
  }

  void removeOptionItem(String groupLocalId, String itemLocalId) {
    final updatedGroups = state.optionGroups.map((group) {
      if (group.localId == groupLocalId) {
        final updatedItems = List<OptionItem>.from(group.items)
          ..removeWhere((item) => item.localId == itemLocalId);
        return group.copyWith(items: updatedItems);
      }
      return group;
    }).toList();
    emit(state.copyWith(optionGroups: updatedGroups));
  }



  // --- GERENCIAMENTO DE DISPONIBILIDADE (Refatorado com localId) ---

  void availabilityTypeChanged(AvailabilityType newType) {
    if (newType == AvailabilityType.always) {
      // Se "Sempre disponível", limpa as regras.
      emit(state.copyWith(
        availabilityType: newType,
        schedules: [],
      ));
    } else {
      // Se "Agendado"...
      List<ScheduleRule> newSchedules = List.from(state.schedules);
      // ...e não houver nenhuma regra, adiciona a primeira.
      if (newSchedules.isEmpty) {
        newSchedules.add(ScheduleRule(localId: _uuid.v4()));
      }
      emit(state.copyWith(
        availabilityType: newType,
        schedules: newSchedules,
      ));
    }
  }

  // ✅ NOVO: Método para adicionar mais regras de horário
  void addScheduleRule() {
    final newRule = ScheduleRule(localId: _uuid.v4());
    final updatedSchedules = List<ScheduleRule>.from(state.schedules)..add(newRule);
    emit(state.copyWith(schedules: updatedSchedules));
  }

  // ✅ NOVO: Método para remover uma regra de horário
  void removeScheduleRule(String ruleLocalId) {
    final updatedSchedules = List<ScheduleRule>.from(state.schedules)
      ..removeWhere((rule) => rule.localId == ruleLocalId);
    emit(state.copyWith(schedules: updatedSchedules));
  }

  // ✅ CORRIGIDO: Agora recebe 'ruleLocalId' em vez de 'ruleIndex'
  void toggleDay(String ruleLocalId, int dayIndex) {
    final updatedSchedules = state.schedules.map((rule) {
      if (rule.localId == ruleLocalId) {
        final updatedDays = List<bool>.from(rule.days);
        updatedDays[dayIndex] = !updatedDays[dayIndex];
        return rule.copyWith(days: updatedDays);
      }
      return rule;
    }).toList();
    emit(state.copyWith(schedules: updatedSchedules));
  }

  // ✅ CORRIGIDO: Agora recebe 'ruleLocalId'
  void updateShiftTime(String ruleLocalId, int shiftIndex, TimeOfDay newTime, {required bool isStart}) {
    final updatedSchedules = state.schedules.map((rule) {
      if (rule.localId == ruleLocalId) {
        final updatedShifts = List<TimeShift>.from(rule.shifts);
        final shiftToUpdate = updatedShifts[shiftIndex];
        updatedShifts[shiftIndex] = isStart
            ? shiftToUpdate.copyWith(startTime: newTime)
            : shiftToUpdate.copyWith(endTime: newTime);
        return rule.copyWith(shifts: updatedShifts);
      }
      return rule;
    }).toList();
    emit(state.copyWith(schedules: updatedSchedules));
  }

  // ✅ CORRIGIDO: Agora recebe 'ruleLocalId'
  void addShift(String ruleLocalId) {
    final updatedSchedules = state.schedules.map((rule) {
      if (rule.localId == ruleLocalId) {
        final updatedShifts = List<TimeShift>.from(rule.shifts)..add(const TimeShift());
        return rule.copyWith(shifts: updatedShifts);
      }
      return rule;
    }).toList();
    emit(state.copyWith(schedules: updatedSchedules));
  }

  // ✅ CORRIGIDO: Agora recebe 'ruleLocalId'
  void removeShift(String ruleLocalId, int shiftIndex) {
    final updatedSchedules = state.schedules.map((rule) {
      if (rule.localId == ruleLocalId) {
        final updatedShifts = List<TimeShift>.from(rule.shifts);
        if (updatedShifts.length > 1) { // Só permite remover se houver mais de um
          updatedShifts.removeAt(shiftIndex);
        }
        return rule.copyWith(shifts: updatedShifts);
      }
      return rule;
    }).toList();
    emit(state.copyWith(schedules: updatedSchedules));
  }

  // --- AÇÕES FINAIS ---
  void cancelWizard() {
    emit(state.copyWith(status: FormStatus.cancelled));
  }

  Future<void> submitCategory() async {
    if (state.categoryName.trim().isEmpty || state.categoryType == null) return;
    emit(state.copyWith(status: FormStatus.loading));

    final categoryData = Category(
      id: state.editingCategoryId,
      name: state.categoryName.trim(),
      type: state.categoryType!,
      active: state.isActive,
      priority: int.tryParse(state.priority) ?? 0,
      cashbackType: state.cashbackType,
      cashbackValue: double.tryParse(state.cashbackValue.replaceAll(',', '.')) ?? 0.0,
      printerDestination: state.printerDestination.isNotEmpty ? state.printerDestination : null,

      // ✅ MAPEAMENTO SIMPLIFICADO: A lista de OptionGroups já está pronta no estado.
      optionGroups: state.optionGroups,

      schedules: state.schedules,
      availabilityType: state.availabilityType,
      pricingStrategy: state.pricingStrategy,
        priceVariesBySize: state.priceVariesBySize,
    );

    final result = (state.editingCategoryId != null)
        ? await categoryRepository.updateCategory(storeId, categoryData)
        : await categoryRepository.createCategory(storeId, categoryData);

    result.fold(
          (error) {
        if (!isClosed) emit(state.copyWith(status: FormStatus.error, errorMessage: error));
      },
          (success) {
        if (!isClosed) emit(state.copyWith(status: FormStatus.success, createdCategory: success));
      },
    );
  }
}















