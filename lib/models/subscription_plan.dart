class SubscriptionPlan {

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.maxTotems,

    required this.interval,
  });

  final int id;
  final String name;
  final int price;
  final int? maxTotems;

  final int interval;

  bool get isPaid => price > 0;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['plan_name'],
      price: json['price'],
      maxTotems: json['max_totems'],

      interval: json['interval'],
    );
  }

}