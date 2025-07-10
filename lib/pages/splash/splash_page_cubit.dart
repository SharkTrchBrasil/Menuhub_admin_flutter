import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:totem_pro_admin/pages/splash/splash_page_state.dart';
import '../../services/auth_service.dart';

class SplashPageCubit extends Cubit<SplashPageState> {
  final AuthService _authService;

  SplashPageCubit({
    AuthService? authService,
  })  : _authService = authService ?? GetIt.I<AuthService>(),
        super(SplashPageState.initial());

  Future<void> initialize() async {
    emit(state.copyWith(loading: true));

    try {
      final authResult = await _authService.initializeApp();

      authResult.fold(
            (error) => emit(state.copyWith(
          loading: false,
          error: error.toString(),
        )),
            (_) => emit(state.copyWith(loading: false)),
      );
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
      ));
    }
  }
}
