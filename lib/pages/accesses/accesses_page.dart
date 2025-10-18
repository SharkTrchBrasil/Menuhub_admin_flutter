import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/app_list_controller.dart';
import 'package:totem_pro_admin/core/di.dart';


import 'package:totem_pro_admin/pages/accesses/widgets/add_user_side_panel.dart';
import 'package:totem_pro_admin/repositories/auth_repository.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/widgets/app_confirmation_dialog.dart';
import 'package:totem_pro_admin/widgets/app_page_header.dart';
import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_table.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart';

import '../../core/enums/store_access.dart';
import '../../core/helpers/sidepanel.dart';
import '../../models/store/store_access.dart';
import '../../repositories/store_repository.dart';
import '../../widgets/ds_primary_button.dart';
import '../../widgets/fixed_header.dart';

class AccessesPage extends StatefulWidget {
  const AccessesPage({super.key, required this.storeId});

  final int storeId;

  @override
  State<AccessesPage> createState() => _AccessesPageState();
}

class _AccessesPageState extends State<AccessesPage> {
  final StoreRepository storeRepository = getIt();
  final AuthRepository authRepository = getIt();

  late final AppListController<StoreAccess> controller =
  AppListController<StoreAccess>(
    fetch: () => storeRepository.getStoreAccesses(widget.storeId),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header moderno
            _buildHeader(),
            const SizedBox(height: 32),
            // Conteúdo da tabela
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [

        FixedHeader(
          title: 'Gestão de Usuários',
          subtitle: 'Gerencie os acessos e permissões dos usuários',
          showActionsOnMobile: true,
          actions: [
            DsButton(
              label: 'Adicionar',
              style: DsButtonStyle.secondary,
              icon: Icons.logout,
              onPressed: addUser,
            ),
          ],
        ),





      ],
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          return AppPageStatusBuilder<List<StoreAccess>>(
            status: controller.status,
            tryAgain: controller.refresh,
            successBuilder: (users) {
              if (users.isEmpty) {
                return _buildEmptyState();
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 768) {
                    return _buildMobileList(users);
                  } else {
                    return _buildDesktopTable(users);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDesktopTable(List<StoreAccess> users) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: AppTable<StoreAccess>(
        items: users,
        columns: [
          AppTableColumnString(
            title: 'Usuário',
            dataSelector: (c) => c.user.name,
          ),
          AppTableColumnString(
            title: 'E-mail',
            dataSelector: (c) => c.user.email,
          ),
          AppTableColumnString(
            title: 'Função',
            dataSelector: (c) => c.role.title,
          ),
          AppTableColumnWidget(
            title: 'Ações',
            width: const FixedColumnWidth(120),
            dataSelector: (c) {
              return _buildActionButtons(c);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(List<StoreAccess> users) {
    return ListView.separated(
   //   padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (context, index) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final user = users[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
           border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          user.user.email,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildActionButtons(user),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getRoleColor(user.role),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.role.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum usuário encontrado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Adicione o primeiro usuário para gerenciar os acessos',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            DsButton(
              label: 'Adicionar Usuário',
              onPressed: addUser,
              icon: Icons.person_add_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(StoreAccess storeAccess) {
    final canDelete = authRepository.user!.id != storeAccess.user.id &&
        storeAccess.role != StoreAccessRole.owner;

    if (!canDelete) {
      return const SizedBox.shrink();
    }

    return IconButton(
      onPressed: () => deleteStoreAccess(storeAccess),
      icon: Icon(
        Icons.delete_outline_rounded,
        color: Colors.grey[600],
      ),
      tooltip: 'Remover usuário',
    );
  }

  Color _getRoleColor(StoreAccessRole role) {
    switch (role) {
      case StoreAccessRole.owner:
        return Colors.redAccent;
      case StoreAccessRole.manager:
        return Colors.blueAccent;
      case StoreAccessRole.cashier:
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }
  }

  Future<void> addUser() async {


    // ✅ ADICIONE: showResponsiveSidePanel
    final result = await showResponsiveSidePanel(
      context,
      AddUserSidePanel(storeId: widget.storeId),
    );

    if (result != null && result && mounted) {
      controller.refresh();
    }
  }

  Future<void> deleteStoreAccess(StoreAccess storeAccess) async {
    final confirmed = await showDialog(
      context: context,
      builder: (_) => AppConfirmationDialog(
        title: 'Remover Usuário',
        description:
        'Tem certeza que deseja remover ${storeAccess.user.name}? Este usuário perderá o acesso à loja.',

      ),
    );
    if (confirmed != null && confirmed) {
      final l = showLoading();
      final result = await storeRepository.revokeAccess(
          widget.storeId, storeAccess.user.id);
      l();
      if (result.isRight) {
        showSuccess('Usuário removido com sucesso!');
        controller.refresh();
      } else {
        showError('Falha ao remover usuário!');
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}