import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/dashboard_data.dart';

import '../../../core/enums/cashback_type.dart';
import '../../../core/enums/dashboard_status.dart';



class DashboardState extends Equatable {
  /// O status atual da busca de dados (ex: loading, success).
  final DashboardStatus status;

  /// Os dados do dashboard recebidos da API. É nulo nos estados `initial`, `loading` e `error`.
  final DashboardData? data;

  /// A mensagem de erro, caso ocorra uma falha na busca.
  final String? errorMessage;

  /// O intervalo de data atualmente selecionado pelo usuário.
  final DateFilterRange selectedRange;

  /// Construtor da classe de estado.
  const DashboardState({
    required this.status,
    this.data,
    this.errorMessage,
    // Define um valor padrão para o filtro, que será usado na inicialização.
    this.selectedRange = DateFilterRange.last30Days,
  });

  /// Um construtor de fábrica para o estado inicial, para facilitar a criação.
  factory DashboardState.initial() {
    return const DashboardState(status: DashboardStatus.initial);
  }

  /// O método `copyWith` é essencial para o BLoC.
  /// Ele permite criar uma nova cópia do estado com algumas propriedades alteradas,
  /// sem modificar o estado original (imutabilidade).
  DashboardState copyWith({
    DashboardStatus? status,
    DashboardData? data,
    String? errorMessage,
    DateFilterRange? selectedRange,
  }) {
    return DashboardState(
      status: status ?? this.status,
      data: data ?? this.data,
      // Limpa os dados em caso de erro para não mostrar dados antigos.
      errorMessage: errorMessage ?? this.errorMessage,
      selectedRange: selectedRange ?? this.selectedRange,
    );
  }

  /// A lista de propriedades que serão usadas pelo `Equatable` para comparar
  /// duas instâncias de `DashboardState`.
  @override
  List<Object?> get props => [status, data, errorMessage, selectedRange];
}