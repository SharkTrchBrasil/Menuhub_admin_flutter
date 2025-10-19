import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../constdata/colorprovider.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/store_manager_cubit.dart';
import '../cubits/store_manager_state.dart';
import '../core/helpers/navigation.dart';

class AppBarCode extends StatelessWidget implements PreferredSizeWidget {
  const AppBarCode({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final currentPath = GoRouterState.of(context).uri.path;

    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded || state.activeStore == null) {
          return AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            title: const Text('Carregando...'),
          );
        }

        final store = state.activeStore!;
        final storeId = store.core.id!;
        final helper = StoreNavigationHelper(storeId);
        final pageTitle = helper.getTitleForPath(currentPath);

        return AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: kToolbarHeight,
          backgroundColor: Colors.white,
          elevation: 0.5,

          // ✅ LEADING: Ícone de menu (mobile) ou título (desktop)
          leadingWidth: isMobile ? 56 : 200,
          leading: isMobile
              ? IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          )
              : Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                pageTitle,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // ✅ TITLE: Nome da loja no centro (mobile)
          centerTitle: isMobile,
          title: isMobile
              ? Text(
            pageTitle,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          )
              : null,

          // ✅ ACTIONS: Menu de usuário e notificações
          actions: [
            // Botão de notificações
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined, color: Colors.black87),
                  // Badge de notificações não lidas
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                // TODO: Implementar painel de notificações
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notificações em desenvolvimento'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),

            const SizedBox(width: 8),

            // Separador vertical
            Container(
              width: 1,
              height: 24,
              margin: const EdgeInsets.symmetric(vertical: 16),
              color: Colors.grey[300],
            ),

            const SizedBox(width: 8),

            // Menu de usuário
            _UserMenuButton(
              store: store,
              isMobile: isMobile,
            ),

            const SizedBox(width: 16),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// MENU DE USUÁRIO (POPUP)
// ═══════════════════════════════════════════════════════════
class _UserMenuButton extends StatelessWidget {
  final dynamic store;
  final bool isMobile;

  const _UserMenuButton({
    required this.store,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final notifire = Provider.of<ColorNotifire>(context);
    final userName = context.read<AuthCubit>().getUserName() ?? 'Usuário';

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Text(
              userName[0].toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  store.core.name,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          ],
        ],
      ),
      itemBuilder: (context) => [
        // Informações do usuário
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                store.core.name,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
            ],
          ),
        ),

        // Meu perfil
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 12),
              const Text('Meu Perfil'),
            ],
          ),
        ),

        // Configurações da loja
        PopupMenuItem<String>(
          value: 'store-settings',
          child: Row(
            children: [
              Icon(Icons.store_outlined, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 12),
              const Text('Configurações da Loja'),
            ],
          ),
        ),

        // Minha assinatura
        PopupMenuItem<String>(
          value: 'subscription',
          child: Row(
            children: [
              Icon(Icons.card_membership_outlined, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 12),
              const Text('Minha Assinatura'),
            ],
          ),
        ),

        // Divider
        const PopupMenuItem<String>(
          enabled: false,
          child: Divider(height: 1),
        ),

        // Dark Mode Toggle
        PopupMenuItem<String>(
          enabled: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.dark_mode_outlined, size: 20, color: Colors.grey[700]),
                  const SizedBox(width: 12),
                  const Text('Modo Escuro'),
                ],
              ),
              Switch(
                value: notifire.getIsDark,
                onChanged: (value) {
                  notifire.isavalable(value);
                  Navigator.pop(context);
                },
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),

        // Divider
        const PopupMenuItem<String>(
          enabled: false,
          child: Divider(height: 1),
        ),

        // Sair
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, size: 20, color: Colors.red),
              const SizedBox(width: 12),
              const Text(
                'Sair',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) async {
        final storeId = store.core.id!;

        switch (value) {
          case 'profile':
          // TODO: Implementar página de perfil
            context.go('/stores/$storeId/settings');
            break;

          case 'store-settings':
            context.go('/stores/$storeId/settings');
            break;

          case 'subscription':
            context.go('/stores/$storeId/manager');
            break;

          case 'logout':
          // Confirmação de logout
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Confirmar Saída'),
                content: const Text('Tem certeza que deseja sair?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Sair'),
                  ),
                ],
              ),
            );

            if (shouldLogout == true && context.mounted) {
              await context.read<AuthCubit>().logout();
              if (context.mounted) {
                context.go('/sign-in');
              }
            }
            break;
        }
      },
    );
  }
}