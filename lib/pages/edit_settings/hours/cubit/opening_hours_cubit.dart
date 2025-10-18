// Em: cubits/opening_hours_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../models/store/store_hour.dart';
import '../../../../repositories/store_repository.dart';
import '../../../../widgets/app_toasts.dart' as AppToasts;
import '../widgets/add_shift_dialog.dart';
import '../widgets/edit_shift_dialog.dart';


part 'opening_hours_state.dart';

class OpeningHoursCubit extends Cubit<OpeningHoursState> {
  final StoreRepository _storeRepository;

  OpeningHoursCubit({
    required StoreRepository storeRepository,
  })  : _storeRepository = storeRepository,
        super(OpeningHoursInitial());

  /// Adiciona novos turnos de horário para uma loja específica.
  Future<void> addHours(int storeId, List<StoreHour> currentHours, AddShiftResult result) async {
    emit(OpeningHoursActionInProgress());

    final List<StoreHour> updatedHours = List.from(currentHours);

    for (final day in result.selectedDays) {
      updatedHours.add(StoreHour(
        dayOfWeek: day,
        openingTime: result.openingTime,
        closingTime: result.closingTime,
        isActive: true,
      ));
    }

    await _updateAndPersistHours(storeId, updatedHours);
  }

  /// Remove um turno de horário de uma loja específica.
  Future<void> removeHour(int storeId, List<StoreHour> currentHours, StoreHour hourToRemove) async {
    emit(OpeningHoursActionInProgress());

    final List<StoreHour> updatedHours = currentHours
        .where((h) =>
    h.dayOfWeek != hourToRemove.dayOfWeek ||
        h.openingTime != hourToRemove.openingTime ||
        h.closingTime != hourToRemove.closingTime)
        .toList();

    await _updateAndPersistHours(storeId, updatedHours);
  }

  /// Atualiza um turno de horário existente em uma loja específica.
  Future<void> updateHour(int storeId, List<StoreHour> currentHours, StoreHour oldHour, EditShiftResult result) async {
    emit(OpeningHoursActionInProgress());

    final List<StoreHour> updatedHours = currentHours.map((h) {
      if (h.dayOfWeek == oldHour.dayOfWeek &&
          h.openingTime == oldHour.openingTime &&
          h.closingTime == oldHour.closingTime) {
        return h.copyWith(
          openingTime: result.openingTime,
          closingTime: result.closingTime,
        );
      }
      return h;
    }).toList();

    await _updateAndPersistHours(storeId, updatedHours);
  }

  /// Método privado para centralizar a lógica de atualização de horários.
  Future<void> _updateAndPersistHours(int storeId, List<StoreHour> updatedHours) async {
    final repoResult = await _storeRepository.updateHours(storeId, updatedHours);

    repoResult.fold(
          (failure) {
        emit(OpeningHoursActionFailure(failure.toString()));
        AppToasts.showError("Falha ao salvar horários: ${failure.toString()}");
      },
          (_) {
        emit(const OpeningHoursActionSuccess('Horários salvos com sucesso!'));
        AppToasts.showSuccess('Horários salvos com sucesso!');
      },
    );
  }
}