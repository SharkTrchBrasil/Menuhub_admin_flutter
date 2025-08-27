// Em lib/pages/dashboard/cubit/dashboard_state.dart

import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/dashboard_data.dart';
import 'package:totem_pro_admin/models/dashboard_insight.dart';
import 'package:totem_pro_admin/models/rating.dart'; // ✅ IMPORTE O MODELO
import 'package:totem_pro_admin/core/enums/dashboard_status.dart';
import 'package:totem_pro_admin/models/payables_dashboard.dart';

import '../../../core/enums/cashback_type.dart';
import '../../../models/rating_summary.dart';

class DashboardState extends Equatable {
  final DashboardStatus status;
  final DashboardData? data;
  final RatingsSummary? ratings; // ✅ ADICIONE A PROPRIEDADE
  final String? errorMessage;
  final DateFilterRange selectedRange;
  final List<DashboardInsight> insights;
  final PayablesDashboardMetrics? payablesMetrics;

  const DashboardState({
    required this.status,
    this.data,
    this.ratings, // ✅ ADICIONE AO CONSTRUTOR
    this.errorMessage,
    this.selectedRange = DateFilterRange.last30Days,
    this.insights = const [],
    this.payablesMetrics,
  });

  factory DashboardState.initial() {
    return const DashboardState(status: DashboardStatus.initial);
  }

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardData? data,
    RatingsSummary? ratings, // ✅ ADICIONE AO COPYWITH
    String? errorMessage,
    DateFilterRange? selectedRange,
    List<DashboardInsight>? insights,
    PayablesDashboardMetrics? payablesMetrics,
  }) {
    return DashboardState(
      status: status ?? this.status,
      data: data ?? this.data,
      ratings: ratings ?? this.ratings, // ✅ ADICIONE AO COPYWITH
      errorMessage: errorMessage ?? this.errorMessage,
      selectedRange: selectedRange ?? this.selectedRange,
      insights: insights ?? this.insights,
      payablesMetrics: payablesMetrics ?? this.payablesMetrics,
    );
  }

  @override
  List<Object?> get props => [status, data, ratings, errorMessage, selectedRange, insights, payablesMetrics];
}