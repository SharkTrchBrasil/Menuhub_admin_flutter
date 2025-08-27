import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/dashboard_data.dart';
import 'package:totem_pro_admin/repositories/dashboard_repository.dart';
// Importe os modelos necessários
import 'package:totem_pro_admin/models/dashboard_insight.dart';

import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import '../../../core/enums/cashback_type.dart';
import '../../../core/enums/dashboard_status.dart';
import '../../../models/payables_dashboard.dart';
import 'dashboard_state.dart';


class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _dashboardRepository;
  final StoresManagerCubit storesManagerCubit;
  final RealtimeRepository _realtimeRepository;

  StreamSubscription? _storesManagerSubscription;
  StreamSubscription? _dashboardDataSubscription;
  StreamSubscription? _payablesDataSubscription;

  DashboardCubit({
    required this.storesManagerCubit,
    required DashboardRepository dashboardRepository,
    required RealtimeRepository realtimeRepository,
  })  : _dashboardRepository = dashboardRepository,
        _realtimeRepository = realtimeRepository,
        super(DashboardState.initial()) {


    _storesManagerSubscription = storesManagerCubit.stream
        .map((state) => state.activeStore?.core.id)
        .distinct() // Só reage se o ID da loja mudar
        .listen(_onActiveStoreChanged);


    if (storesManagerCubit.state.activeStore != null) {
      _onActiveStoreChanged(storesManagerCubit.state.activeStore!.core.id);
    }
  }


  void _onActiveStoreChanged(int? storeId) {
    if (storeId == null) {
      emit(DashboardState.initial());
      return;
    }

    // Cancela o listener antigo para não receber dados de lojas passadas
    _dashboardDataSubscription?.cancel();
    _payablesDataSubscription?.cancel();
    // Inicia o estado de loading para a nova loja
    emit(state.copyWith(status: DashboardStatus.loading, data: null, insights: [],  payablesMetrics: null,));

    // Escuta pelo evento `dashboard_data_updated` que o backend enviará
    _dashboardDataSubscription = _realtimeRepository.onDashboardDataUpdated.listen((dashboardPayload) {
      if (dashboardPayload != null) {
        _processDashboardPayload(dashboardPayload);
      }


    });



    _payablesDataSubscription = _realtimeRepository.onPayablesDashboardUpdated.listen((payablesPayload) {
      if (payablesPayload != null) {
        _processPayablesPayload(payablesPayload);
      }
    });


    // Se os dados já estiverem no estado principal (caso raro), usa-os.
    // Senão, o listener acima vai esperar os dados chegarem.
    final storeState = storesManagerCubit.state;
    if (storeState is StoresManagerLoaded && storeState.activeStore?.relations.dashboardData != null) {
      emit(state.copyWith(
        status: DashboardStatus.success,
        data: storeState.activeStore!.relations.dashboardData,
        insights: storeState.activeStore!.relations.insights,
      ));
    }





  }


  void _processPayablesPayload(PayablesDashboardMetrics payload) {
    // Simplesmente atualiza o estado com os novos dados de contas a pagar.
    // O status da tela já deve ser 'success' por conta do outro payload.
    emit(state.copyWith(payablesMetrics: payload));
  }



  void _processDashboardPayload(Map<String, dynamic> payload) {
    try {
      final dashboardData = DashboardData.fromJson(payload['dashboard']);
      final insights = (payload['insights'] as List)
          .map((i) => DashboardInsight.fromJson(i))
          .toList();

      emit(state.copyWith(
        status: DashboardStatus.success,
        data: dashboardData,
        insights: insights,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.error,
        errorMessage: 'Falha ao processar dados do dashboard: $e',
      ));
    }
  }


  Future<void> changeDateFilter(DateFilterRange newRange) async {
    // ✅ 5. AGORA O FILTRO DE DATA CHAMA A API E ATUALIZA APENAS OS DADOS DO GRÁFICO
    emit(state.copyWith(selectedRange: newRange, status: DashboardStatus.loading));

    try {
      final storeId = storesManagerCubit.state.activeStore!.core.id!;
      final dates = _getDatesForRange(state.selectedRange);
      final newDashboardData = await _dashboardRepository.getDashboardData(
        storeId: storeId,
        startDate: dates['start']!,
        endDate: dates['end']!,
      );

      // Atualiza o estado mantendo os insights que já tínhamos
      emit(state.copyWith(
        status: DashboardStatus.success,
        data: newDashboardData,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }



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
  Future<void> close(){
     _payablesDataSubscription?.cancel();
    _storesManagerSubscription?.cancel();
    _dashboardDataSubscription?.cancel(); // ✅ Cancela a nova inscrição
    return super.close();
  }
}



