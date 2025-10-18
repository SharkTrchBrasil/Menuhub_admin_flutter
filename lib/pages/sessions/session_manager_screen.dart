import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/di.dart';

import 'package:totem_pro_admin/models/active_session.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import 'package:totem_pro_admin/widgets/fixed_header.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';

import '../../repositories/session_manager_repository.dart';
import 'cubit/session_manager_cubit.dart';

class SessionManagerPage extends StatelessWidget {
  const SessionManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SessionManagerCubit(
        repository: getIt<SessionManagerRepository>(),
      )..loadActiveSessions(),
      child: const _SessionManagerView(),
    );
  }
}

class _SessionManagerView extends StatelessWidget {
  const _SessionManagerView();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: FixedHeader(
              title: 'Dispositivos Conectados',
              subtitle: 'Gerencie suas sessões ativas',
              showActionsOnMobile: true,
              actions: [
                DsButton(
                  label: 'Deslogar Todos',
                  style: DsButtonStyle.secondary,
                  icon: Icons.logout,
                  onPressed: () => _showRevokeAllDialog(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<SessionManagerCubit, SessionManagerState>(
              builder: (context, state) {
                if (state is SessionManagerLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SessionManagerError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<SessionManagerCubit>().loadActiveSessions(),
                          child: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is SessionManagerLoaded) {
                  if (state.sessions.isEmpty) {
                    return const Center(child: Text('Nenhuma sessão ativa'));
                  }

                  return RefreshIndicator(
                    onRefresh: () => context.read<SessionManagerCubit>().loadActiveSessions(),
                    child: ListView.builder(
                      padding: EdgeInsets.all(isMobile ? 16 : 24),
                      itemCount: state.sessions.length,
                      itemBuilder: (context, index) {
                        final session = state.sessions[index];
                        return _SessionCard(
                          session: session,
                          isMobile: isMobile,
                          onRevoke: () => _revokeSession(context, session),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showRevokeAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Deslogar Todos os Dispositivos?'),
        content: const Text(
          'Esta ação irá desconectar todos os outros dispositivos, mantendo apenas este.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext);

              final realtimeRepo = getIt<RealtimeRepository>();
              // ✅ CORREÇÃO: Usa o getter público
              final currentSid = realtimeRepo.isConnected ? realtimeRepo.currentSocketId : null;

              if (currentSid == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erro: Sessão atual não encontrada')),
                );
                return;
              }

              final success = await context
                  .read<SessionManagerCubit>()
                  .revokeAllOtherSessions(currentSid);

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Todos os outros dispositivos foram desconectados'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }


  void _revokeSession(BuildContext context, ActiveSession session) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desconectar Dispositivo?'),
        content: Text(
          'Deseja desconectar ${session.deviceName ?? "este dispositivo"}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext);

              final success = await context
                  .read<SessionManagerCubit>()
                  .revokeSession(session.id);

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${session.deviceName ?? "Dispositivo"} desconectado'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final ActiveSession session;
  final bool isMobile;
  final VoidCallback onRevoke;

  const _SessionCard({
    required this.session,
    required this.isMobile,
    required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: session.isCurrent ? Colors.green : Colors.grey.shade200,
          width: session.isCurrent ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                session.deviceIcon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            session.deviceName ?? 'Dispositivo Desconhecido',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: isMobile ? 16 : 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (session.isCurrent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ATUAL',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${session.platform ?? "Plataforma desconhecida"} • ${session.browser ?? "Browser desconhecido"}',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // ✅ CORREÇÃO: Só mostra botão se NÃO for o dispositivo atual
              if (!session.isCurrent)
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  onPressed: onRevoke,
                  tooltip: 'Desconectar',
                )
              // ✅ NOVO: Adiciona espaço vazio se for o dispositivo atual
              // para manter o alinhamento consistente
              else
                const SizedBox(width: 48), // Tamanho do IconButton
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                'Última atividade: ${session.timeAgo}',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          if (session.ipAddress != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'IP: ${session.ipAddress}',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}