import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:totem_pro_admin/models/page_status.dart';
import 'package:totem_pro_admin/models/store/store.dart';

import '../cubit/store_setup-state.dart';
import '../cubit/store_setup_cubit.dart';

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
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  Timer? _messageTimer;
  int _currentMessageIndex = 0;
  final List<String> _loadingMessages = [
    'Estamos criando sua loja...',
    'Configurando seu cardápio inicial...',
    'Aplicando seu plano...',
    'Ajustando os últimos detalhes...',
    'Quase pronto!',
  ];

  bool _isSuccess = false;
  bool _showSuccessContent = false;
  Store? _newStore;

  @override
  void initState() {
    super.initState();

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

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


  void _handleSuccess(Store store) {
    setState(() {
      _isSuccess = true;
      _newStore = store;
    });


    _successController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _showSuccessContent = true;
          });
          _scaleController.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _successController.dispose();
    _scaleController.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 180,
          height: 180,

          child: Lottie.asset(
            'assets/animations/loading.json',
            width: 120,
            height: 120,
          ),
        ),
        const SizedBox(height: 40),
        _buildMessageText(),
        const SizedBox(height: 20),
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessAnimation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 220,
          height: 220,

          child: Lottie.asset(
            'assets/animations/success.json',
            controller: _successController,
            onLoaded: (composition) {
              _successController.duration = composition.duration;
            },
            width: 180,
            height: 180,
          ),
        ),
        const SizedBox(height: 32),
        _buildMessageText(),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.green.shade100,
                width: 4,
              ),
            ),
            child: Icon(
              Icons.check_rounded,
              size: 60,
              color: Colors.green.shade600,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Loja Criada com Sucesso!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 40),
          _buildActionButtons(),
        ],
      ),
    );
  }


  Widget _buildActionButtons() {
    return Column(
      children: [
        FilledButton(
          onPressed: () {
            if (_newStore != null) {
              // ✅ ALTERAÇÃO AQUI: Navega para a rota do wizard
              context.go('/stores/${_newStore!.core.id}/setup');
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Configurar loja',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
// ...

  Widget _buildMessageText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Text(
        _isSuccess
            ? (_showSuccessContent
            ? 'Tudo pronto! Sua loja está ativa.'
            : 'Finalizando configuração...')
            : _loadingMessages[_currentMessageIndex],
        key: ValueKey<String>(_isSuccess.toString() + _currentMessageIndex.toString()),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: _isSuccess ? Colors.green.shade700 : Colors.grey.shade800,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              _handleSuccess(status.data as Store);
            }

            if (status is PageStatusError) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(status.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,

            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: SingleChildScrollView(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _showSuccessContent
                          ? _buildSuccessContent()
                          : (_isSuccess
                          ? _buildSuccessAnimation()
                          : _buildLoadingState()),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}