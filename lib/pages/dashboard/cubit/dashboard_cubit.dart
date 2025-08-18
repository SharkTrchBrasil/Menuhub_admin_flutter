// Em: cubits/dashboard_cubit.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/dashboard_data.dart';
import 'package:totem_pro_admin/repositories/dashboard_repository.dart';
import '../../../core/enums/cashback_type.dart';
import '../../../core/enums/dashboard_status.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _dashboardRepository;
  final StoresManagerCubit storesManagerCubit; // ✅ NOVO: Injeção do cubit principal
  late final StreamSubscription _storesManagerSubscription; // ✅ NOVO: A inscrição

  DashboardCubit({
    required this.storesManagerCubit, // ✅ NOVO
    required DashboardRepository dashboardRepository,
  })  : _dashboardRepository = dashboardRepository,
        super(DashboardState.initial()) {
    // Processa o estado atual do StoresManagerCubit assim que é criado
    _processStoreState(storesManagerCubit.state);

    // E escuta por futuras atualizações
    _storesManagerSubscription = storesManagerCubit.stream.listen(_processStoreState);
  }

  /// ✅ NOVO: Este método reage às mudanças no estado da loja principal
  void _processStoreState(StoresManagerState storeState) {
    if (storeState is StoresManagerLoaded) {
      final dashboardData = storeState.activeStore?.dashboardData;

      if (dashboardData != null) {
        // Se os dados já existem no estado principal, apenas os exiba.
        emit(state.copyWith(status: DashboardStatus.success, data: dashboardData));
      } else {
        // Se por algum motivo os dados não vieram, busca na API como fallback.
        fetchDashboardData();
      }
    }
  }

  Future<void> changeDateFilter(DateFilterRange newRange) async {
    emit(state.copyWith(selectedRange: newRange, status: DashboardStatus.loading));
    await fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    // Só mostra o loading se não tivermos dados
    if (state.status != DashboardStatus.success) {
      emit(state.copyWith(status: DashboardStatus.loading));
    }

    try {
      final storeId = storesManagerCubit.state.activeStore!.core.id!;

      final dates = _getDatesForRange(state.selectedRange);
      final dashboardData = await _dashboardRepository.getDashboardData(
        storeId: storeId,
        startDate: dates['start']!,
        endDate: dates['end']!,
      );

      emit(state.copyWith(
        status: DashboardStatus.success,
        data: dashboardData,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // O resto do cubit permanece o mesmo...
  Map<String, DateTime> _getDatesForRange(DateFilterRange range) {
    // ... sua lógica de datas aqui ...
    final now = DateTime.now();
    final todayAtStartOfDay = DateTime(now.year, now.month, now.day);
    switch (range) {
      case DateFilterRange.today: return {'start': todayAtStartOfDay, 'end': now};
      case DateFilterRange.last7Days: return {'start': todayAtStartOfDay.subtract(const Duration(days: 6)), 'end': now};
      case DateFilterRange.last30Days:
      default: return {'start': todayAtStartOfDay.subtract(const Duration(days: 29)), 'end': now};
    }
  }

  @override
  Future<void> close() {
    _storesManagerSubscription.cancel(); // ✅ NOVO: Cancela a inscrição
    return super.close();
  }
}