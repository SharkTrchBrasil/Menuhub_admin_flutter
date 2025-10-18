
import 'package:totem_pro_admin/services/pagarme_service.dart';

class CreateSubscriptionPayload {
final String cardToken;
final String cardMask;

CreateSubscriptionPayload({
required this.cardToken,
required this.cardMask,
});

/// ✅ Factory conveniente que recebe PagarmeTokenResult
///
/// Uso:
/// ```dart
/// final tokenResult = await pagarmeService.tokenizeCard(...);
/// final payload = CreateSubscriptionPayload.fromTokenResult(tokenResult);
/// ```
factory CreateSubscriptionPayload.fromTokenResult(
PagarmeTokenResult tokenResult,
) {
return CreateSubscriptionPayload(
cardToken: tokenResult.token,
cardMask: tokenResult.cardMask,
);
}

/// Converte para JSON no formato esperado pelo backend
///
/// Formato:
/// ```json
/// {
///   "card": {
///     "payment_token": "tok_abc123xyz",
///     "card_mask": "************1234"
///   }
/// }
/// ```
Map<String, dynamic> toJson() {
return {
'card': {
'payment_token': cardToken,
'card_mask': cardMask,
}
};
}

@override
String toString() =>
'CreateSubscriptionPayload(cardToken: ${cardToken.substring(0, 10)}..., cardMask: $cardMask)';
}