import 'package:totem_pro_admin/models/subscription_summary.dart';
import '../../cubits/store_manager_cubit.dart';
import '../../cubits/store_manager_state.dart';

/// Enum para especificar qual tipo de limite estamos verificando.
/// Usar um enum torna o código mais seguro e legível do que usar strings.
enum LimitType {
  products,
  categories,
  users,
  monthlyOrders,
  locations,
  banners,
  activeDevices,
}

/// Um objeto de resultado para a verificação de limites.
/// Nos diz se a ação é permitida, qual o limite e qual a contagem atual.
class LimitCheckResult {
  final bool isAllowed;
  final int? limit;
  final int currentCount;

  const LimitCheckResult({
    required this.isAllowed,
    this.limit,
    required this.currentCount,
  });

  /// Retorna true se o plano for ilimitado para este recurso.
  bool get isUnlimited => limit == null;
}

/// Serviço singleton para gerenciar o controle de acesso a funcionalidades (features)
/// e a verificação de limites de uso baseados no plano de assinatura da loja ativa.
class AccessControlService {
  final StoresManagerCubit _storesManagerCubit;

  // Agora armazenamos a assinatura completa para ter acesso aos limites.
  SubscriptionSummary? _subscription;

  AccessControlService(this._storesManagerCubit) {
    _storesManagerCubit.stream.listen((state) {
      if (state is StoresManagerLoaded) {
        _updateSubscription(state.activeStore?.relations.subscription);
      } else {
        _updateSubscription(null);
      }
    });

    // Garante que o estado inicial também seja carregado
    final initialState = _storesManagerCubit.state;
    if (initialState is StoresManagerLoaded) {
      _updateSubscription(initialState.activeStore?.relations.subscription);
    }
  }

  /// Atualiza os dados da assinatura interna do serviço.
  void _updateSubscription(SubscriptionSummary? subscription) {
    _subscription = subscription;
    if (subscription != null) {
      print("✅ AccessControlService: Assinatura e limites atualizados para o plano '${subscription.planName}'.");
    } else {
      print("❌ AccessControlService: Nenhuma assinatura ativa. Permissões e limites limpos.");
    }
  }

  // --- ✅ NOVO GETTER CENTRAL DE SEGURANÇA ---
  /// O "porteiro" do serviço. Verifica de forma centralizada se existe uma
  /// assinatura e se ela está com o status 'active'.
  /// Todas as outras verificações devem usar este getter.
  bool get isSubscriptionActive {
    return _subscription != null && _subscription!.status == 'active';
  }

  // --- MÉTODOS PARA FEATURES (LIGADO/DESLIGADO) ---

  /// Verifica se a assinatura atual tem acesso a uma funcionalidade específica.
  bool canAccess(String featureKey) {
    // Agora a verificação é mais limpa e segura.
    if (!isSubscriptionActive) return false;
    return _subscription!.features.contains(featureKey);
  }

  // --- NOVOS MÉTODOS PARA LIMITES (CONTAGEM) ---

  /// Verifica se a contagem atual de um recurso está dentro do limite do plano.
  ///
  /// Exemplo de uso:
  /// final result = accessControl.checkLimit(LimitType.products, 49);
  /// if (result.isAllowed) { /* Pode criar mais um produto */ }
  LimitCheckResult checkLimit(LimitType type, int currentCount) {
    // Usa o getter central para a verificação inicial.
    if (!isSubscriptionActive) {
      return LimitCheckResult(isAllowed: false, limit: 0, currentCount: currentCount);
    }

    int? limit;

    // Pega o limite correto com base no tipo solicitado
    switch (type) {
      case LimitType.products:
        limit = _subscription!.productLimit;
        break;
      case LimitType.categories:
        limit = _subscription!.categoryLimit;
        break;
      case LimitType.users:
        limit = _subscription!.userLimit;
        break;
      case LimitType.monthlyOrders:
        limit = _subscription!.monthlyOrderLimit;
        break;
      case LimitType.locations:
        limit = _subscription!.locationLimit;
        break;
      case LimitType.banners:
        limit = _subscription!.bannerLimit;
        break;
      case LimitType.activeDevices:
        limit = _subscription!.maxActiveDevices;
        break;
    }

    // Se o limite for nulo, é ilimitado.
    if (limit == null) {
      return LimitCheckResult(isAllowed: true, limit: null, currentCount: currentCount);
    }

    // A ação é permitida se a contagem atual for MENOR que o limite.
    final bool isAllowed = currentCount < limit;

    return LimitCheckResult(isAllowed: isAllowed, limit: limit, currentCount: currentCount);
  }
}
