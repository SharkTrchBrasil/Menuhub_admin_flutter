import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// Seus imports
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/plans/available_plan.dart';



import '../../models/page_status.dart';
import '../../repositories/store_repository.dart'; // Ajuste o caminho se necessário

class EditSubscriptionPageController extends ChangeNotifier {
  final int _storeId;
  final _subscriptionRepository = GetIt.I<StoreRepository>();
  final _storesManagerCubit = GetIt.I<StoresManagerCubit>();

  // ✅ A única variável de estado. Ela começa como 'loading'.
  PageStatus _status = PageStatusLoading();
  PageStatus get status => _status;

  // ❌ A lista de planos foi REMOVIDA daqui. Ela viverá dentro do PageStatusSuccess.
  // List<AvailablePlan> _plans = [];

  // Mapa para nomes amigáveis (continua igual)
  final Map<String, String> _featureDisplayNames = {
    'chatbot': 'Chatbot',
    'totem': 'Módulo de Totem',
    'style_guide': 'Design Personalizável',
    'advanced_reports': 'Relatórios Avançados',
  };

  EditSubscriptionPageController(this._storeId) {
    _fetchData();
  }

  String getFeatureDisplayName(String featureKey) {
    return _featureDisplayNames[featureKey] ?? featureKey;
  }

  Future<void> _fetchData() async {
    _status = PageStatusLoading();
    notifyListeners();

    final storeState = _storesManagerCubit.state;
    if (storeState is! StoresManagerLoaded) {
      _status = PageStatusError("Não foi possível carregar os dados da loja.");
      notifyListeners();
      return;
    }
    final activeStore = storeState.activeStore;

    final plansResult = await _subscriptionRepository.getPlans();

    plansResult.fold(
          (failure) {
        _status = PageStatusError(failure.message);
        notifyListeners();
      },
          (allPlans) {
        if (allPlans.isEmpty) {
          _status = PageStatusEmpty("Nenhum plano de assinatura foi encontrado.");
        } else {
         final currentPlanId = activeStore?.relations.subscription?.planId;
          final finalPlans = allPlans.map((plan) {
            return AvailablePlan(
              plan: plan,
              isCurrent: plan.id == currentPlanId,
            );
          }).toList();

          // ✅ O sucesso agora carrega os dados DENTRO do objeto de estado
          _status = PageStatusSuccess(finalPlans);
        }
        notifyListeners();
      },
    );
  }

  void reload() => _fetchData();
}