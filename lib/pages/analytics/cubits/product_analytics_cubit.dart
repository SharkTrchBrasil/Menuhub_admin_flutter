// lib/pages/analytics/product_analytics/cubit/product_analytics_cubit.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// Importe seus modelos e o Cubit/State principal da loja
import 'package:totem_pro_admin/models/product_analytics_data.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';

part 'product_analytics_state.dart';

class ProductAnalyticsCubit extends Cubit<ProductAnalyticsState> {
  // Dependência do Cubit principal que contém os dados da loja
  final StoresManagerCubit storesManagerCubit;
  // Usado para "escutar" as atualizações do Cubit principal
  late final StreamSubscription _storesManagerSubscription;

  ProductAnalyticsCubit({required this.storesManagerCubit}) : super(ProductAnalyticsInitial()) {
    // Logo que o Cubit é criado, ele processa o estado atual do StoresManagerCubit
    _processState(storesManagerCubit.state);

    // E começa a escutar por futuras atualizações de estado
    _storesManagerSubscription = storesManagerCubit.stream.listen(_processState);
  }

  void _processState(StoresManagerState state) {
    // Verifica se o estado principal é o de sucesso (loja carregada)
    if (state is StoresManagerLoaded) {
      final analyticsData = state.activeStore?.productAnalytics;

      if (analyticsData != null) {
        // Se temos os dados de análise, emitimos o estado de sucesso
        emit(ProductAnalyticsLoaded(analyticsData));
      } else {
        // Se por algum motivo os dados não vieram, emitimos um erro
        emit(const ProductAnalyticsError("Dados de análise de produtos não encontrados."));
      }
    }
  }

  // É MUITO IMPORTANTE cancelar a inscrição para evitar vazamentos de memória
  @override
  Future<void> close() {
    _storesManagerSubscription.cancel();
    return super.close();
  }
}