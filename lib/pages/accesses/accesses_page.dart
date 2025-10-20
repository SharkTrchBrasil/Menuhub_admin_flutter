// pages/accesses/accesses_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/app_list_controller.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/pages/accesses/widgets/add_user_side_panel.dart';
import 'package:totem_pro_admin/repositories/auth_repository.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/widgets/app_confirmation_dialog.dart';
import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
import 'package:totem_pro_admin/widgets/app_table.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import 'package:totem_pro_admin/widgets/fixed_header.dart';

import '../../core/enums/store_access.dart';
import '../../core/helpers/sidepanel.dart';
import '../../models/store/store_access.dart';

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
  void initState() {
    super.initState();
    controller.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(

          children: [
            // ✅ Header fixo responsivo
            _buildHeader(context),

            // ✅ Conteúdo principal
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: EdgeInsets.all(
                      constraints.maxWidth < 600 ? 16 : 24,
                    ),
                    child: _buildContent(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return FixedHeader(
      title: 'Gestão de Usuários',
      subtitle: 'Gerencie os acessos e permissões dos usuários da loja',
      showActionsOnMobile: true,
      actions: [
        DsButton(
          label: isMobile ? 'Adicionar' : 'Adicionar Usuário',
          style: DsButtonStyle.primary,
          icon: Icons.person_add_rounded,
          onPressed: _addUser,

        ),
      ],
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                  final isMobile = constraints.maxWidth < 768;
                  return Padding(
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ Header da tabela/listagem
                        _buildListHeader(users, isMobile),

                        const SizedBox(height: 16),

                        // ✅ Conteúdo (tabela ou lista)
                        Expanded(
                          child: isMobile
                              ? _buildMobileList(users)
                              : _buildDesktopTable(users),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildListHeader(List<StoreAccess> users, bool isMobile) {
    return Row(
      children: [
        Icon(
          Icons.people_rounded,
          color: Colors.grey.shade600,
          size: isMobile ? 18 : 20,
        ),
        const SizedBox(width: 8),
        Text(
          '${users.length} ${users.length == 1 ? 'usuário' : 'usuários'}',
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),

      ],
    );
  }

  Widget _buildDesktopTable(List<StoreAccess> users) {
    return AppTable<StoreAccess>(
      items: users,
      columns: [
        AppTableColumnWidget(
          title: 'Usuário',
          dataSelector: (c) => _buildUserCell(c, false),
        ),
        AppTableColumnString(
          title: 'E-mail',
          dataSelector: (c) => c.user.email,
        ),
        AppTableColumnWidget(
          title: 'Função',
          width: const FixedColumnWidth(150),
          dataSelector: (c) => _buildRoleBadge(c.role, false),
        ),
        AppTableColumnWidget(
          title: 'Ações',
          width: const FixedColumnWidth(100),
          dataSelector: (c) => _buildActionButtons(c, false),
        ),
      ],
    );
  }

  Widget _buildUserCell(StoreAccess access, bool isMobile) {
    return Row(
      children: [
        CircleAvatar(
          radius: isMobile ? 16 : 18,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            access.user.name[0].toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 12 : 14,
            ),
          ),
        ),
        SizedBox(width: isMobile ? 8 : 12),
        Expanded(
          child: Text(
            access.user.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 13 : 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleBadge(StoreAccessRole role, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 12,
        vertical: isMobile ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: _getRoleColor(role).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getRoleColor(role).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRoleIcon(role),
            size: isMobile ? 12 : 14,
            color: _getRoleColor(role),
          ),
          SizedBox(width: isMobile ? 4 : 6),
          Text(
            role.title,
            style: TextStyle(
              color: _getRoleColor(role),
              fontSize: isMobile ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(List<StoreAccess> users) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = users[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Header do card
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Text(
                      user.user.name[0].toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
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
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.user.email,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildActionButtons(user, true),
                ],
              ),
              const SizedBox(height: 12),
              _buildRoleBadge(user.role, true),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isMobile ? 80 : 120,
                height: isMobile ? 80 : 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.people_outline_rounded,
                  size: isMobile ? 40 : 60,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Nenhum usuário encontrado',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                  fontSize: isMobile ? 18 : null,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Adicione o primeiro usuário para gerenciar os acessos à loja',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: isMobile ? 13 : 14,
                ),
              ),
              const SizedBox(height: 32),
              DsButton(
                label: 'Adicionar Primeiro Usuário',
                onPressed: _addUser,
                icon: Icons.person_add_rounded,

              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(StoreAccess storeAccess, bool isMobile) {
    final canDelete = authRepository.user!.id != storeAccess.user.id &&
        storeAccess.role != StoreAccessRole.owner;

    if (!canDelete) {
      return Tooltip(
        message: 'Não é possível remover este usuário',
        child: Icon(
          Icons.lock_outline,
          color: Colors.grey.shade400,
          size: isMobile ? 18 : 20,
        ),
      );
    }

    return IconButton(
      onPressed: () => _deleteStoreAccess(storeAccess),
      icon: Icon(
        Icons.delete_outline_rounded,
        color: Colors.red.shade400,
        size: isMobile ? 18 : 20,
      ),
      tooltip: 'Remover usuário',
      constraints: const BoxConstraints(),
      padding: EdgeInsets.all(isMobile ? 6 : 8),
    );
  }

  Color _getRoleColor(StoreAccessRole role) {
    switch (role) {
      case StoreAccessRole.owner:
        return Colors.purple;
      case StoreAccessRole.manager:
        return Colors.blue;
      case StoreAccessRole.cashier:
        return Colors.green;
      case StoreAccessRole.waiter:
        return Colors.orange;
      case StoreAccessRole.stockManager:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(StoreAccessRole role) {
    switch (role) {
      case StoreAccessRole.owner:
        return Icons.microwave;
      case StoreAccessRole.manager:
        return Icons.admin_panel_settings_rounded;
      case StoreAccessRole.cashier:
        return Icons.point_of_sale_rounded;
      case StoreAccessRole.waiter:
        return Icons.room_service_rounded;
      case StoreAccessRole.stockManager:
        return Icons.inventory_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  // ✅ ABRE SIDE PANEL (USA DADOS DO CUBIT)
  Future<void> _addUser() async {
    final storesState = context.read<StoresManagerCubit>().state;

    if (storesState is! StoresManagerLoaded) {
      showError('Erro ao carregar dados das lojas');
      return;
    }

    final result = await showResponsiveSidePanel<bool>(
      context,
      BlocProvider.value(
        value: context.read<StoresManagerCubit>(),
        child: AddUserSidePanel(
          storeId: widget.storeId,
          availableStores: storesState.stores.values.toList(),
        ),
      ),
      useHalfScreenOnDesktop: false,
    );

    if (result == true && mounted) {
      controller.refresh();
    }
  }

  Future<void> _deleteStoreAccess(StoreAccess storeAccess) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AppConfirmationDialog(
        title: 'Remover Usuário',
        description:
        'Tem certeza que deseja remover ${storeAccess.user.name}? Este usuário perderá o acesso à loja.',
      ),
    );

    if (confirmed != true) return;

    final l = showLoading();
    final result = await storeRepository.revokeAccess(
      widget.storeId,
      storeAccess.user.id,
    );
    l();

    if (!mounted) return;

    if (result.isRight) {
      showSuccess('Usuário removido com sucesso!');
      controller.refresh();
    } else {
      showError('Falha ao remover usuário!');
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}