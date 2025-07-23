class TokenizedCard {
  TokenizedCard({
    required this.paymentToken,
    required this.cardMask,
  });

  final String paymentToken;
  final String cardMask;

  factory TokenizedCard.fromJson(Map<String, dynamic> json) {
    return TokenizedCard(
      paymentToken: json['payment_token'],
      cardMask: json['card_mask'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_token': paymentToken,
      'card_mask': cardMask,
    };
  }
}
