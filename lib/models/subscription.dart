import 'package:totem_pro_admin/models/subscription_plan.dart';

class Subscription {

  Subscription({
    required this.id,
    required this.plan,
  });

  final int id;
  final SubscriptionPlan plan;

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      plan: SubscriptionPlan.fromJson(json['plan']),
    );
  }

}