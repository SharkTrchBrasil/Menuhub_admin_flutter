
import '../address.dart';
import '../billing_customer.dart';
import 'tokenized_card.dart';

class CreateSubscriptionPayload {
  final int planId;
  // ✅ Adicionado '?' para tornar os campos opcionais
  final Address? address;
  final BillingCustomer? customer;
  final TokenizedCard? card;

  const CreateSubscriptionPayload({
    required this.planId,
    // ✅ Removido o 'required' para que possam ser nulos
    this.address,
    this.customer,
    this.card,
  });

  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
      // ✅ Usa o operador '?.' para chamar toJson() somente se o objeto não for nulo
      'address': address?.toJson(),
      'customer': customer?.toJson(),
      'card': card?.toJson(),
    };
  }
}