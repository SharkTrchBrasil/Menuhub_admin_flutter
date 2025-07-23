enum SubscriptionStatus {
  /// A assinatura está paga e dentro da validade.
  active,

  /// A assinatura venceu, mas está no período de carência (3 dias).
  gracePeriod,

  /// A assinatura e o período de carência expiraram.
  expired,

  /// O status ainda não foi determinado (estado inicial).
  unknown
}