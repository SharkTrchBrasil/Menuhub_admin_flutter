import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:totem_pro_admin/pages/splash/splash_page_state.dart';
// import '../../services/auth_service.dart'; // Não precisa mais do AuthService aqui diretamente para inicializar

class SplashPageCubit extends Cubit<SplashPageState> {
  // Não precisa mais do AuthService aqui, pois ele não vai inicializar o app
  // final AuthService _authService;

  SplashPageCubit() : super(SplashPageState.initial());

  // Remova o método initialize() ou mude sua lógica
  // para apenas aguardar um período ou uma condição
  // antes de indicar que a tela de splash está pronta para sumir.
  // A inicialização real do app será feita pelo AuthCubit no MultiProvider.
  Future<void> simulateLoading() async {
    emit(state.copyWith(loading: true));
    await Future.delayed(const Duration(seconds: 1)); // Simula um pequeno carregamento
    emit(state.copyWith(loading: false));
  }
}