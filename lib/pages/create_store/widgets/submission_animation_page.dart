import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:totem_pro_admin/models/page_status.dart';
import 'package:totem_pro_admin/models/store.dart';

import '../cubit/store_setup_cubit.dart';
import '../cubit/store_setup-state.dart';

class SubmissionAnimationPage extends StatefulWidget {
  final StoreSetupCubit storeSetupCubit;
  const SubmissionAnimationPage({super.key, required this.storeSetupCubit});

  @override
  State<SubmissionAnimationPage> createState() =>
      _SubmissionAnimationPageState();
}

class _SubmissionAnimationPageState extends State<SubmissionAnimationPage>
    with TickerProviderStateMixin {
  late final AnimationController _successController;

  Timer? _messageTimer;
  int _currentMessageIndex = 0;
  final List<String> _loadingMessages = [
    'Estamos criando sua loja...',
    'Configurando seu cardápio inicial...',
    'Aplicando seu plano gratuito...',
    'Ajustando os últimos detalhes...',
    'Quase pronto!',
  ];

  bool _isSuccess = false;
  Store? _newStore;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(vsync: this);

    // O redirecionamento foi removido daqui e colocado no botão.

    _startMessageTimer();
  }

  void _startMessageTimer() {
    _messageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentMessageIndex =
              (_currentMessageIndex + 1) % _loadingMessages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _successController.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Escolha a frase de sucesso que preferir.
    final message = _isSuccess
        ? 'A criação da sua loja foi concluída. Prossiga para o painel de controle para iniciar a configuração.'
        : _loadingMessages[_currentMessageIndex];

    return BlocProvider.value(
      value: widget.storeSetupCubit,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocListener<StoreSetupCubit, StoreSetupState>(
          listenWhen: (prev, current) =>
          prev.submissionStatus != current.submissionStatus,
          listener: (context, state) {
            final status = state.submissionStatus;

            if (status is PageStatusSuccess || status is PageStatusError) {
              _messageTimer?.cancel();
            }

            if (status is PageStatusSuccess) {
              setState(() {
                _isSuccess = true;
                _newStore = status.data as Store;
              });
            }

            if (status is PageStatusError) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(status.message), backgroundColor: Colors.red),
              );
            }
          },
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isSuccess)
                    Lottie.asset(
                      'assets/animations/success.json',
                      controller: _successController,
                      onLoaded: (composition) {
                        _successController
                          ..duration = composition.duration
                          ..forward();
                      },
                      width: 400, // Diminuí um pouco para dar espaço ao botão
                      height: 400,
                    )
                  else
                    Lottie.asset(
                      'assets/animations/loading.json',
                      width: 200,
                      height: 200,
                    ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Text(
                      message,
                      key: ValueKey<String>(message), // Mudei a key para a própria mensagem
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48), // Espaço para o botão

                  // ✅ BOTÃO APARECE APENAS NO SUCESSO
                  if (_isSuccess)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        if (_newStore != null) {
                          // A rota para as configurações gerais é um bom começo.
                          context.go('/stores/${_newStore!.core.id}/dashboard');
                        }
                      },
                      child: const Text('Acessar Painel'), // Texto do botão
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}