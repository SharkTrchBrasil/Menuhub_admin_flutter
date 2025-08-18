// lib/pages/analytics/customer_analytics/cubit/customer_analytics_cubit.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// Importe seus modelos e o Cubit/State principal da loja
import 'package:totem_pro_admin/models/customer_analytics_data.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';

part 'customer_analytics_state.dart';

class CustomerAnalyticsCubit extends Cubit<CustomerAnalyticsState> {
  final StoresManagerCubit storesManagerCubit;
  late final StreamSubscription _storesManagerSubscription;

  CustomerAnalyticsCubit({required this.storesManagerCubit}) : super(CustomerAnalyticsInitial()) {
    // Processa o estado atual assim que o cubit é criado
    _processState(storesManagerCubit.state);

    // E escuta por futuras atualizações
    _storesManagerSubscription = storesManagerCubit.stream.listen(_processState);
  }

  void _processState(StoresManagerState state) {
    if (state is StoresManagerLoaded) {
      // A única mudança é aqui: pegamos 'customerAnalytics'
      final analyticsData = state.activeStore?.customerAnalytics;

      if (analyticsData != null) {
        emit(CustomerAnalyticsLoaded(analyticsData));
      } else {
        emit(const CustomerAnalyticsError("Dados de análise de clientes não encontrados."));
      }
    }
  }

  @override
  Future<void> close() {
    _storesManagerSubscription.cancel();
    return super.close();
  }
}