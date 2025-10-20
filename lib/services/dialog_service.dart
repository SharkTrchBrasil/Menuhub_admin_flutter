

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';


class DialogService {







 


























  /// Exibe um diálogo de confirmação genérico.
  /// Retorna `true` se o usuário confirmar (pressionar 'Sim'), `false` caso contrário.
  static Future<bool?> showConfirmationDialog(
      BuildContext context, {
        required String title,
        required String content,
        String confirmButtonText = 'Sim', // Texto padrão para o botão de confirmação
        String cancelButtonText = 'Cancelar', // Texto padrão para o botão de cancelamento
      }) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title.tr()), // Usa .tr() para internacionalização
          content: Text(content.tr()), // Usa .tr() para internacionalização
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Retorna false ao cancelar
              },
              child: Text(cancelButtonText.tr()),
            ),
            FilledButton( // Usar FilledButton para a ação primária (confirmação)
              onPressed: () {
                Navigator.of(context).pop(true); // Retorna true ao confirmar
              },
              child: Text(confirmButtonText.tr()),
            ),
          ],
        );
      },
    );
  }


// Adicione mais diálogos aqui conforme necessário
}
