import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

//==============================================================================
// ESTADO (STATE)
//==============================================================================

/// Representa o estado da UI customizável do Scaffold principal (o "Shell").
///
/// Guarda os widgets que podem ser dinamicamente alterados pelas páginas filhas,
/// como a AppBar e o FloatingActionButton.
class ScaffoldUiState extends Equatable {
  /// O AppBar que a página atual deseja exibir.
  /// Pode ser nulo se nenhuma AppBar for necessária.
  final PreferredSizeWidget? appBar;

  /// O FloatingActionButton que a página atual deseja exibir.
  /// Pode ser nulo se nenhum FAB for necessário.
  final FloatingActionButton? fab;

  const ScaffoldUiState({
    this.appBar,
    this.fab,
  });

  /// Cria uma cópia do estado atual com os novos valores fornecidos.
  ScaffoldUiState copyWith({
    // Usamos um truque com 'ValueGetter' para poder passar 'null' explicitamente.
    ValueGetter<PreferredSizeWidget?>? appBar,
    ValueGetter<FloatingActionButton?>? fab,
  }) {
    return ScaffoldUiState(
      appBar: appBar != null ? appBar() : this.appBar,
      fab: fab != null ? fab() : this.fab,
    );
  }

  @override
  List<Object?> get props => [appBar, fab];
}


//==============================================================================
// CUBIT
//==============================================================================

/// Gerencia o estado da UI do Scaffold principal (`AppShell`).
///
/// Atua como uma ponte, permitindo que as páginas filhas (dentro do ShellRoute)
/// configurem a aparência do Scaffold pai (a "moldura").
class ScaffoldUiCubit extends Cubit<ScaffoldUiState> {
  ScaffoldUiCubit() : super(const ScaffoldUiState());

  /// Define o AppBar a ser exibido no Scaffold principal.
  /// Chame isso no `initState` da sua página filha.
  void setAppBar(PreferredSizeWidget appBar) {
    emit(state.copyWith(appBar: () => appBar));
  }

  /// Define o FloatingActionButton a ser exibido no Scaffold principal.
  /// Chame isso no `initState` da sua página filha.
  void setFab(FloatingActionButton fab) {
    emit(state.copyWith(fab: () => fab));
  }

  /// Limpa todos os widgets customizáveis, revertendo ao estado inicial.
  /// Chame isso no `dispose` da sua página filha para evitar que a AppBar ou o FAB
  /// de uma página "vazem" para a próxima.
  void clearAll() {
    emit(const ScaffoldUiState(appBar: null, fab: null));
  }
}