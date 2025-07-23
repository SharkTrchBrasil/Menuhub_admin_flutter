import 'package:totem_pro_admin/models/address.dart';
import 'package:totem_pro_admin/models/billing_customer.dart';
import 'package:totem_pro_admin/models/subscription_plan.dart';
import 'package:totem_pro_admin/models/tokenized_card.dart';

class NewSubscription {

  NewSubscription({
    required this.plan,
    this.customer,
    this.card,
    this.address,
  });

  final SubscriptionPlan plan;
  final BillingCustomer? customer;
  final TokenizedCard? card;
  final Address? address;

  Map<String, dynamic> toJson() {
    return {
      'plan_id': plan.id,
      'customer': customer?.toJson(),
      'card': card?.toJson(),
      'address': address?.toJson(),
    };
  }

}