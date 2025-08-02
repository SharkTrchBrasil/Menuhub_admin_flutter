
import 'package:totem_pro_admin/models/plans.dart';

class AvailablePlan {
  final Plans plan;
  final bool isCurrent; // True se este for o plano atual da loja

  const AvailablePlan({
    required this.plan,
    required this.isCurrent,
  });
}