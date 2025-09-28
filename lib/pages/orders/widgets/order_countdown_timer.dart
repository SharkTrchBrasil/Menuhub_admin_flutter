import 'dart:async';
import 'package:flutter/material.dart';

class OrderCountdownTimer extends StatefulWidget {
  /// A data e hora em que o pedido foi criado.
  final DateTime createdAt;

  /// Duração total em minutos a partir da qual o countdown começa.
  final int totalDurationInMinutes;

  const OrderCountdownTimer({
    super.key,
    required this.createdAt,
    this.totalDurationInMinutes = 8, // Padrão de 8 minutos, como no iFood
  });

  @override
  State<OrderCountdownTimer> createState() => _OrderCountdownTimerState();
}

class _OrderCountdownTimerState extends State<OrderCountdownTimer> {
  late Timer _timer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel(); // Essencial para evitar memory leaks
    super.dispose();
  }

  void _startTimer() {
    // Calcula o momento exato em que o pedido "expira"
    final deadline = widget.createdAt.add(Duration(minutes: widget.totalDurationInMinutes));

    // Cria um timer que roda a cada segundo
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final remaining = deadline.difference(now);

      if (remaining.isNegative) {
        // Se o tempo acabou, para o timer e zera o tempo
        setState(() => _remainingTime = Duration.zero);
        timer.cancel();
      } else {
        // Caso contrário, atualiza o estado com o tempo restante
        setState(() => _remainingTime = remaining);
      }
    });
  }

  // Função que decide a cor baseada no tempo restante
  Color _getProgressColor() {
    final minutes = _remainingTime.inMinutes;
    if (minutes < 2) {
      return Colors.red.shade700; // Últimos 2 minutos
    } else if (minutes < 5) {
      return Colors.orange.shade600; // Entre 5 e 2 minutos
    } else {
      return Colors.green.shade600; // Mais de 5 minutos
    }
  }

  @override
  Widget build(BuildContext context) {
    // Formata o tempo restante para o formato "mm:ss"
    final minutes = _remainingTime.inMinutes.toString().padLeft(2, '0');
    final seconds = (_remainingTime.inSeconds % 60).toString().padLeft(2, '0');
    final timeString = '$minutes:$seconds';

    // Calcula o progresso percentual para a animação do círculo
    final totalSeconds = widget.totalDurationInMinutes * 60;
    final progress = _remainingTime.inSeconds / totalSeconds;

    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          // O círculo de progresso que "esvazia"
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 4.0,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
          ),
          // O texto com o tempo restante
          Center(
            child: Text(
              timeString,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: _getProgressColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}