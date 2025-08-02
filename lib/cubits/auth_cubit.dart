import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/repositories/auth_repository.dart';
import 'package:totem_pro_admin/services/auth_service.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';

// Importando o modelo para ter acesso a 'TotemAuthAndStores'.
import 'package:totem_pro_admin/models/totem_auth_and_stores.dart';

import '../models/store_with_role.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;


  AuthCubit({
    required AuthService authService,


  })  : _authService = authService,

        super(AuthInitial()) {
    _initializeApp();
  }


  Future<void> _initializeApp() async {
    print('[AuthCubit] Initializing app...');
    if (state is! AuthLoading) {
      emit(AuthLoading());
    }

    // O AuthService agora lida com a inicialização do RealtimeRepository.
    final result = await _authService.initializeApp();

    result.fold(
          (error) {
        print('[AuthCubit] App initialization failed: $error');
        emit(AuthUnauthenticated());
      },
          (data) {
        // ✅ CORREÇÃO: A inicialização do RealtimeRepository foi removida daqui.
        // O AuthService já fez isso com o token JWT correto.
        print('[AuthCubit] App initialized and RealtimeRepository is connected. Emitting AuthAuthenticated.');
        emit(AuthAuthenticated(data));
      },
    );
  }

  Future<void> signIn(String email, String password) async {
    print('[AuthCubit] Attempting sign-in for $email...');
    emit(AuthLoading());

    // O AuthService agora lida com o login E a inicialização do RealtimeRepository.
    final result = await _authService.signIn(email: email, password: password);

    result.fold(
      // Lado esquerdo (Erro)
          (error) {
        // LÓGICA ATUALIZADA
        if (error == SignInError.emailNotVerified) {
          // Se o erro for de e-mail não verificado,
          // emita o estado de verificação!
          emit(AuthNeedsVerification(email: email, password: password));
        } else {
          // Para todos os outros erros, emita o estado de erro genérico.
          emit(AuthError(error));
        }
      },
      // Lado direito (Sucesso)
          (data) {
        emit(AuthAuthenticated(data));
      },
    );



  }

  Future<void> logout() async {
    print('[AuthCubit] Logging out...');
    emit(AuthLoading());

    // O AuthService já chama o dispose do RealtimeRepository.
    await _authService.logout();

    print('[AuthCubit] Logout complete.');
    emit(AuthUnauthenticated());
  }

  Future<void> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    print('[AuthCubit] Attempting sign-up for $email...');
    emit(AuthLoading());
    final result = await _authService.signUp(name: name, phone: phone, email: email, password: password);
    result.fold(
          (error) {
        print('[AuthCubit] Sign-up failed: $error');
        emit(AuthSignUpError(error));
      },
          (_) {
        print('[AuthCubit] Sign-up successful. Emitting AuthUnauthenticated for login/verification.');

        emit(AuthNeedsVerification(email: email, password: password));
       // emit(AuthUnauthenticated());
      },
    );
  }




  // 👇 COLE O NOVO MÉTODO AQUI 👇
  Future<void> verifyCodeAndLogin({required String code}) async {
    // 1. Garante que estamos no estado correto para ter as credenciais.
    final currentState = state;
    if (currentState is! AuthNeedsVerification) {
      // Medida de segurança, não deve acontecer no fluxo normal.
      return;
    }

    emit(AuthLoading()); // Mostra um indicador de carregamento na tela.

    // 2. Pega o e-mail e a senha que estavam guardados no estado.
    final email = currentState.email;
    final password = currentState.password;

    // 3. Chama o repositório para verificar o código.
    final verifyResult = await _authService.verifyCode(
      email: email,
      code: code,
    );

    // O 'await' aqui garante que esperamos a verificação terminar.
    await verifyResult.fold(
          (error) async {
        // Se a verificação do código falhar, voltamos ao estado anterior
        // para que o usuário possa tentar de novo.
        // Você pode criar um `AuthState` de erro específico para mostrar uma mensagem.
        emit(currentState);
      },
          (_) async {
        // 4. SUCESSO! Se o código foi verificado,
        // chamamos o método de login que já existe, reutilizando toda a lógica.
        print('[AuthCubit] Código verificado. Tentando login automático...');
        await signIn(email, password);
      },
    );
  }




  // ✅ ADICIONE ESTE NOVO MÉTODO
  void addNewStore(StoreWithRole newStoreWithRole) {
    // Pega o estado atual
    final currentState = state;

    // Garante que estamos autenticados antes de tentar atualizar
    if (currentState is AuthAuthenticated) {
      // Cria uma nova lista de lojas, adicionando a nova loja no início
      final updatedStores = [newStoreWithRole, ...currentState.data.stores];

      // Cria uma nova instância do nosso objeto de dados com a lista atualizada
      final updatedData = TotemAuthAndStores(
        totemAuth: currentState.data.totemAuth,
        user: currentState.data.user,
        stores: updatedStores,
      );

      // Emite um novo estado de autenticado com os dados atualizados
      emit(AuthAuthenticated(updatedData));
      print('[AuthCubit] Nova loja adicionada ao estado global.');
    }
  }








  @override
  Future<void> close() {
    print('[AuthCubit] AuthCubit closed.');
    return super.close();
  }
}
