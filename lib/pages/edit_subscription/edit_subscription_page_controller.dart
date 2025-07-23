import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/models/page_status.dart';
import 'package:totem_pro_admin/models/subscription_plan.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';

class EditSubscriptionPageController extends ChangeNotifier {
  EditSubscriptionPageController(this.storeId) {
    _initialize();
  }

  final int storeId;

  final StoreRepository _storeRepository = getIt();

  PageStatus status = PageStatusIdle();

  Future<void> _initialize() async {
    status = PageStatusLoading();
    notifyListeners();

    final currentSubscription =
        _storeRepository.stores
            .firstWhere((s) => s.store.id == storeId)
            .store
            .subscription; // já é do tipo StoreSubscription


    final plansResult = await _storeRepository.getPlans();
    if (plansResult.isRight) {
      final plans = plansResult.right;

      final availablePlans =
          plans.map((plan) {
            return AvailablePlan(plan, plan.id == currentSubscription!.plan.id);
          }).toList();

      if (!plans.any((p) => p.id == currentSubscription!.plan.id)) {
        availablePlans.add(AvailablePlan(currentSubscription!.plan, true));
      }

      availablePlans.sort((a, b) => a.plan.price.compareTo(b.plan.price));

      status = PageStatusSuccess(availablePlans);
    } else {
      status = PageStatusError('Falha ao buscar planos de assinatura');
    }

    notifyListeners();
  }

  void reload() => _initialize();
}

class AvailablePlan {
  AvailablePlan(this.plan, this.isCurrent);

  final SubscriptionPlan plan;
  final bool isCurrent;
}
