import 'package:flutter/services.dart';

class ValueRangeTextInputFormatter extends TextInputFormatter {
  final double min;
  final double max;

  ValueRangeTextInputFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Permite que o usuário apague o campo
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // O CurrencyTextInputFormatter usa vírgula, então trocamos para ponto para o parse
    final numericValue = double.tryParse(newValue.text.replaceAll(',', '.'));

    // Se o valor não for um número válido (ex: o usuário digitou "12,"),
    // permite a entrada para que o outro formatador possa agir.
    if (numericValue == null) {
      return newValue;
    }

    // A verificação principal: se o valor está dentro do intervalo permitido
    if (numericValue >= min && numericValue <= max) {
      return newValue; // Permite a mudança
    }

    // Se o valor estiver fora do intervalo, rejeita a mudança mantendo o valor antigo
    return oldValue;
  }
}