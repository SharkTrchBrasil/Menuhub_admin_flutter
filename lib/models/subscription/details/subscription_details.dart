import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/subscription/details/billing_preview.dart';
import 'package:totem_pro_admin/models/subscription/details/billing_history_item.dart';
import 'package:totem_pro_admin/models/subscription/subscription.dart';

import 'card_info.dart';


/// Detalhes completos da assinatura para tela de gerenciamento
class SubscriptionDetails extends Equatable {
  final Subscription subscription;
  final BillingPreview billingPreview;
  final List<BillingHistoryItem> billingHistory;
  final CardInfo? cardInfo;
  final bool canCancel;

  const SubscriptionDetails({
    required this.subscription,
    required this.billingPreview,
    required this.billingHistory,
    this.cardInfo,
    required this.canCancel,
  });

  factory SubscriptionDetails.fromJson(Map<String, dynamic> json) {
    return SubscriptionDetails(
      subscription: Subscription.fromJson(json['subscription']),
      billingPreview: BillingPreview.fromJson(json['billing_preview']),
      billingHistory: (json['billing_history'] as List<dynamic>)
          .map((e) => BillingHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      cardInfo: json['card_info'] != null
          ? CardInfo.fromJson(json['card_info'])
          : null,
      canCancel: json['can_cancel'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
    subscription,
    billingPreview,
    billingHistory,
    cardInfo,
    canCancel,
  ];
}