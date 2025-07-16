class StoreSubscription {
  final String? planName;
  final int? price;
  final int? interval;
  final String? status;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final bool? isRecurring;
  final Map<String, bool>? features;

  StoreSubscription({
    this.planName,
    this.price,
    this.interval,
    this.status,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.isRecurring,
    this.features,
  });



  // Métodos adicionais para verificação de status
  bool get isActive => status == 'active';
  bool get isInTrial => status == 'trialing';
  bool get isPastDue => status == 'past_due';
  bool get isCanceled => status == 'canceled';



// Verifica se está perto do vencimento (3 dias ou menos)
  bool get isNearExpiration {
    if (currentPeriodEnd == null) return false;
    final now = DateTime.now();
    final difference = currentPeriodEnd!.difference(now).inDays;
    return difference <= 3 && difference >= 0;
  }

// Verifica se está vencido
  bool get isExpired {
    if (currentPeriodEnd == null) return false;
    return DateTime.now().isAfter(currentPeriodEnd!);
  }

// Verifica se está em período de carência (7 dias após vencimento)
  bool get isInGracePeriod {
    if (currentPeriodEnd == null) return false;
    final now = DateTime.now();
    final gracePeriodEnd = currentPeriodEnd!.add(const Duration(days: 7));
    return now.isAfter(currentPeriodEnd!) && now.isBefore(gracePeriodEnd);
  }

// Dias restantes para o vencimento (pode ser negativo se vencido)
  int get daysUntilExpiration {
    if (currentPeriodEnd == null) return 0;
    return currentPeriodEnd!.difference(DateTime.now()).inDays;
  }





  factory StoreSubscription.fromJson(Map<String, dynamic> json) {
    // --- Debug: Imprime o JSON de entrada para StoreSubscription ---
    print('[DEBUG: StoreSubscription.fromJson] JSON de entrada: $json');

    // Extrai os dados do 'plan' aninhado, se existirem
    final Map<String, dynamic>? planData = json['plan'] as Map<String, dynamic>?;

    // Combina os dados da raiz da assinatura com os dados do plano (se existirem)
    // Isso garante que 'status', 'current_period_end', etc. sejam capturados,
    // e 'plan_name', 'price', etc. sejam adicionados se o 'plan' estiver presente.
    final Map<String, dynamic> combinedJson = {
      ...json, // Copia todas as chaves da raiz da assinatura
      if (planData != null) ...{
        'plan_name': planData['plan_name'],
        'price': planData['price'],
        'interval': planData['interval'],
        // Transforma a lista de features em um mapa key: value
        'features': {
          for (var f in (planData['features'] as List<dynamic>?) ?? [])
            if (f is Map<String, dynamic> && f.containsKey('feature_key'))
              f['feature_key'].toString(): f['is_enabled'] ?? false
        },
      },
    };

    // --- Debug: Imprime o JSON combinado para StoreSubscription ---
    print('[DEBUG: StoreSubscription.fromJson] JSON combinado: $combinedJson');


    return StoreSubscription(
      planName: combinedJson['plan_name'] as String?,
      price: combinedJson['price'] as int?,
      interval: combinedJson['interval'] as int?,
      status: combinedJson['status'] as String?,
      currentPeriodStart: combinedJson['current_period_start'] != null
          ? DateTime.tryParse(combinedJson['current_period_start'])
          : null,
      currentPeriodEnd: combinedJson['current_period_end'] != null
          ? DateTime.tryParse(combinedJson['current_period_end'])
          : null,
      isRecurring: combinedJson['is_recurring'] as bool?,
      features: (combinedJson['features'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as bool),
      ),
    );
  }













}

