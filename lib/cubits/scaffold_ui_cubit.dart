import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

//==============================================================================
// ESTADO (STATE) - Adicionamos a flag 'showDrawer'
//==============================================================================
class ScaffoldUiState extends Equatable {
  final PreferredSizeWidget? appBar;
  final FloatingActionButton? fab;
  final bool showDrawer; // ✅ NOVO CAMPO

  const ScaffoldUiState({
    this.appBar,
    this.fab,
    this.showDrawer = true, // ✅ Por padrão, o drawer é visível
  });

  ScaffoldUiState copyWith({
    ValueGetter<PreferredSizeWidget?>? appBar,
    ValueGetter<FloatingActionButton?>? fab,
    bool? showDrawer, // ✅
  }) {
    return ScaffoldUiState(
      appBar: appBar != null ? appBar() : this.appBar,
      fab: fab != null ? fab() : this.fab,
      showDrawer: showDrawer ?? this.showDrawer, // ✅
    );
  }

  @override
  List<Object?> get props => [appBar, fab, showDrawer]; // ✅
}


//==============================================================================
// CUBIT - Adicionamos o método 'setShowDrawer'
//==============================================================================
class ScaffoldUiCubit extends Cubit<ScaffoldUiState> {
  ScaffoldUiCubit() : super(const ScaffoldUiState());

  void setAppBar(PreferredSizeWidget? appBar) {
    emit(state.copyWith(appBar: () => appBar));
  }

  void setFab(FloatingActionButton? fab) {
    emit(state.copyWith(fab: () => fab));
  }

  // ✅ NOVO MÉTODO PARA CONTROLAR O DRAWER
  void setShowDrawer(bool show) {
    emit(state.copyWith(showDrawer: show));
  }

  /// Limpa todos os widgets customizáveis, revertendo ao estado inicial.
  void clearAll() {
    // Agora também reseta o drawer para o padrão (visível)
    emit(const ScaffoldUiState(appBar: null, fab: null, showDrawer: true));
  }
}