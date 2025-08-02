import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/di.dart';

import '../core/feature_registry.dart';
import '../dialogs/upgrade_dialog.dart';
import '../services/subscription/subscription_service.dart'; // Seu arquivo GetIt


class AccessWrapper extends StatelessWidget {
  /// A chave da feature a ser verificada (ex: 'kds_module').
  final String featureKey;


  /// O widget filho que será exibido se o acesso for permitido.
  final Widget child;

  const AccessWrapper({
    super.key,
    required this.featureKey,

    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Pega a instância do serviço de controle de acesso
    final accessControl = getIt<AccessControlService>();

    // Verifica se o usuário tem acesso à feature
    final bool hasAccess = accessControl.canAccess(featureKey);

    if (hasAccess) {
      // Se tiver acesso, simplesmente retorna o widget filho.
      return child;
    } else {
      // Se NÃO tiver acesso, retorna uma versão "bloqueada" do widget.
      return GestureDetector(
        onTap: () {
          // ✅ PASSO 3: Busque o nome no nosso registro central.
          // O `?? featureKey` é uma segurança: se esquecermos de adicionar
          // ao registro, ele usará a própria chave em vez de quebrar.
          final String featureName = featureRegistry[featureKey] ?? featureKey;

          showUpgradeDialog(context, featureName);
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. O filho com opacidade reduzida e sem interação.
            IgnorePointer(
              ignoring: true,
              child: Opacity(
                opacity: 0.5,
                child: child,
              ),
            ),
            // 2. Um ícone de cadeado sobreposto.
            Container(
              padding: const EdgeInsets.all(8),

              child: const Icon(
                Icons.lock,
                color: Colors.red,
                size: 24,
              ),
            ),
          ],
        ),
      );
    }
  }
}