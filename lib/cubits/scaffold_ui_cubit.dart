import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

//==============================================================================
// ESTADO (STATE) - JÁ ESTAVA CORRETO
//==============================================================================
class ScaffoldUiState extends Equatable {
  final PreferredSizeWidget? appBar;
  final FloatingActionButton? fab;

  const ScaffoldUiState({
    this.appBar,
    this.fab,
  });

  ScaffoldUiState copyWith({
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
// CUBIT - CORRIGIDO
//==============================================================================
class ScaffoldUiCubit extends Cubit<ScaffoldUiState> {
  ScaffoldUiCubit() : super(const ScaffoldUiState());

  /// Define o AppBar a ser exibido no Scaffold principal.
  /// Passe `null` para remover a AppBar customizada e usar a padrão do AppShell.
  void setAppBar(PreferredSizeWidget? appBar) { // ✅ CORREÇÃO AQUI
    emit(state.copyWith(appBar: () => appBar));
  }

  /// Define o FloatingActionButton a ser exibido no Scaffold principal.
  void setFab(FloatingActionButton? fab) { // ✅ CORREÇÃO AQUI
    emit(state.copyWith(fab: () => fab));
  }

  /// Limpa todos os widgets customizáveis, revertendo ao estado inicial.
  void clearAll() {
    emit(const ScaffoldUiState(appBar: null, fab: null));
  }
}