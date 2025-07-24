
import 'package:totem_pro_admin/models/plan.dart';

class AvailablePlan {
  final Plan plan;
  final bool isCurrent; // True se este for o plano atual da loja

  const AvailablePlan({
    required this.plan,
    required this.isCurrent,
  });
}